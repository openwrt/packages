/*
 * cgi-io - LuCI non-RPC helper
 *
 *   Copyright (C) 2013 Jo-Philipp Wich <jo@mein.io>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#define _GNU_SOURCE /* splice(), SPLICE_F_MORE */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <ctype.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/sendfile.h>
#include <sys/ioctl.h>
#include <linux/fs.h>

#include <libubus.h>
#include <libubox/blobmsg.h>

#include "multipart_parser.h"

#ifndef O_TMPFILE
#define O_TMPFILE	(020000000 | O_DIRECTORY)
#endif

#define READ_BLOCK 4096
#define POST_LIMIT 131072

enum part {
	PART_UNKNOWN,
	PART_SESSIONID,
	PART_FILENAME,
	PART_FILEMODE,
	PART_FILEDATA
};

const char *parts[] = {
	"(bug)",
	"sessionid",
	"filename",
	"filemode",
	"filedata",
};

struct state
{
	bool is_content_disposition;
	enum part parttype;
	char *sessionid;
	char *filename;
	bool filedata;
	int filemode;
	int filefd;
	int tempfd;
};

enum {
	SES_ACCESS,
	__SES_MAX,
};

static const struct blobmsg_policy ses_policy[__SES_MAX] = {
	[SES_ACCESS] = { .name = "access", .type = BLOBMSG_TYPE_BOOL },
};


static struct state st;

static void
session_access_cb(struct ubus_request *req, int type, struct blob_attr *msg)
{
	struct blob_attr *tb[__SES_MAX];
	bool *allow = (bool *)req->priv;

	if (!msg)
		return;

	blobmsg_parse(ses_policy, __SES_MAX, tb, blob_data(msg), blob_len(msg));

	if (tb[SES_ACCESS])
		*allow = blobmsg_get_bool(tb[SES_ACCESS]);
}

static bool
session_access(const char *sid, const char *scope, const char *obj, const char *func)
{
	uint32_t id;
	bool allow = false;
	struct ubus_context *ctx;
	static struct blob_buf req;

	ctx = ubus_connect(NULL);

	if (!ctx || ubus_lookup_id(ctx, "session", &id))
		goto out;

	blob_buf_init(&req, 0);
	blobmsg_add_string(&req, "ubus_rpc_session", sid);
	blobmsg_add_string(&req, "scope", scope);
	blobmsg_add_string(&req, "object", obj);
	blobmsg_add_string(&req, "function", func);

	ubus_invoke(ctx, id, "access", req.head, session_access_cb, &allow, 500);

out:
	if (ctx)
		ubus_free(ctx);

	return allow;
}

static char *
checksum(const char *applet, size_t sumlen, const char *file)
{
	pid_t pid;
	int r;
	int fds[2];
	static char chksum[65];

	if (pipe(fds))
		return NULL;

	switch ((pid = fork()))
	{
	case -1:
		return NULL;

	case 0:
		uloop_done();

		dup2(fds[1], 1);

		close(0);
		close(2);
		close(fds[0]);
		close(fds[1]);

		if (execl("/bin/busybox", "/bin/busybox", applet, file, NULL))
			return NULL;

		break;

	default:
		memset(chksum, 0, sizeof(chksum));
		r = read(fds[0], chksum, sumlen);

		waitpid(pid, NULL, 0);
		close(fds[0]);
		close(fds[1]);

		if (r < 0)
			return NULL;
	}

	return chksum;
}

static char *
datadup(const void *in, size_t len)
{
	char *out = malloc(len + 1);

	if (!out)
		return NULL;

	memcpy(out, in, len);

	*(out + len) = 0;

	return out;
}

static bool
urldecode(char *buf)
{
	char *c, *p;

	if (!buf || !*buf)
		return true;

#define hex(x) \
	(((x) <= '9') ? ((x) - '0') : \
		(((x) <= 'F') ? ((x) - 'A' + 10) : \
			((x) - 'a' + 10)))

	for (c = p = buf; *p; c++)
	{
		if (*p == '%')
		{
			if (!isxdigit(*(p + 1)) || !isxdigit(*(p + 2)))
				return false;

			*c = (char)(16 * hex(*(p + 1)) + hex(*(p + 2)));

			p += 3;
		}
		else if (*p == '+')
		{
			*c = ' ';
			p++;
		}
		else
		{
			*c = *p++;
		}
	}

	*c = 0;

	return true;
}

static char *
postdecode(char **fields, int n_fields)
{
	const char *var;
	char *p, *postbuf;
	int i, field, found = 0;
	ssize_t len = 0, rlen = 0, content_length = 0;

	var = getenv("CONTENT_TYPE");

	if (!var || strncmp(var, "application/x-www-form-urlencoded", 33))
		return NULL;

	var = getenv("CONTENT_LENGTH");

	if (!var)
		return NULL;

	content_length = strtol(var, &p, 10);

	if (p == var || content_length <= 0 || content_length >= POST_LIMIT)
		return NULL;

	postbuf = calloc(1, content_length + 1);

	if (postbuf == NULL)
		return NULL;

	for (len = 0; len < content_length; )
	{
		rlen = read(0, postbuf + len, content_length - len);

		if (rlen <= 0)
			break;

		len += rlen;
	}

	if (len < content_length)
	{
		free(postbuf);
		return NULL;
	}

	for (p = postbuf, i = 0; i <= len; i++)
	{
		if (postbuf[i] == '=')
		{
			postbuf[i] = 0;

			for (field = 0; field < (n_fields * 2); field += 2)
			{
				if (!strcmp(p, fields[field]))
				{
					fields[field + 1] = postbuf + i + 1;
					found++;
				}
			}
		}
		else if (postbuf[i] == '&' || postbuf[i] == '\0')
		{
			postbuf[i] = 0;

			if (found >= n_fields)
				break;

			p = postbuf + i + 1;
		}
	}

	for (field = 0; field < (n_fields * 2); field += 2)
	{
		if (!urldecode(fields[field + 1]))
		{
			free(postbuf);
			return NULL;
		}
	}

	return postbuf;
}

static char *
canonicalize_path(const char *path, size_t len)
{
	char *canonpath, *cp;
	const char *p, *e;

	if (path == NULL || *path == '\0')
		return NULL;

	canonpath = datadup(path, len);

	if (canonpath == NULL)
		return NULL;

	/* normalize */
	for (cp = canonpath, p = path, e = path + len; p < e; ) {
		if (*p != '/')
			goto next;

		/* skip repeating / */
		if ((p + 1 < e) && (p[1] == '/')) {
			p++;
			continue;
		}

		/* /./ or /../ */
		if ((p + 1 < e) && (p[1] == '.')) {
			/* skip /./ */
			if ((p + 2 >= e) || (p[2] == '/')) {
				p += 2;
				continue;
			}

			/* collapse /x/../ */
			if ((p + 2 < e) && (p[2] == '.') && ((p + 3 >= e) || (p[3] == '/'))) {
				while ((cp > canonpath) && (*--cp != '/'))
					;

				p += 3;
				continue;
			}
		}

next:
		*cp++ = *p++;
	}

	/* remove trailing slash if not root / */
	if ((cp > canonpath + 1) && (cp[-1] == '/'))
		cp--;
	else if (cp == canonpath)
		*cp++ = '/';

	*cp = '\0';

	return canonpath;
}

static int
response(bool success, const char *message)
{
	char *chksum;
	struct stat s;

	printf("Status: 200 OK\r\n");
	printf("Content-Type: text/plain\r\n\r\n{\n");

	if (success)
	{
		if (!stat(st.filename, &s))
			printf("\t\"size\": %u,\n", (unsigned int)s.st_size);
		else
			printf("\t\"size\": null,\n");

		chksum = checksum("md5sum", 32, st.filename);
		printf("\t\"checksum\": %s%s%s,\n",
			chksum ? "\"" : "",
			chksum ? chksum : "null",
			chksum ? "\"" : "");

		chksum = checksum("sha256sum", 64, st.filename);
		printf("\t\"sha256sum\": %s%s%s\n",
			chksum ? "\"" : "",
			chksum ? chksum : "null",
			chksum ? "\"" : "");
	}
	else
	{
		if (message)
			printf("\t\"message\": \"%s\",\n", message);

		printf("\t\"failure\": [ %u, \"%s\" ]\n", errno, strerror(errno));

		if (st.filefd > -1)
			unlink(st.filename);
	}

	printf("}\n");

	return -1;
}

static int
failure(int code, int e, const char *message)
{
	printf("Status: %d %s\r\n", code, message);
	printf("Content-Type: text/plain\r\n\r\n");
	printf("%s", message);

	if (e)
		printf(": %s", strerror(e));

	printf("\n");

	return -1;
}

static int
filecopy(void)
{
	int len;
	char buf[READ_BLOCK];

	if (!st.filedata)
	{
		close(st.tempfd);
		errno = EINVAL;
		return response(false, "No file data received");
	}

	snprintf(buf, sizeof(buf), "/proc/self/fd/%d", st.tempfd);

	if (unlink(st.filename) < 0 && errno != ENOENT)
	{
		close(st.tempfd);
		return response(false, "Failed to unlink existing file");
	}

	if (linkat(AT_FDCWD, buf, AT_FDCWD, st.filename, AT_SYMLINK_FOLLOW) < 0)
	{
		if (lseek(st.tempfd, 0, SEEK_SET) < 0)
		{
			close(st.tempfd);
			return response(false, "Failed to rewind temp file");
		}

		st.filefd = open(st.filename, O_CREAT | O_TRUNC | O_WRONLY, 0600);

		if (st.filefd < 0)
		{
			close(st.tempfd);
			return response(false, "Failed to open target file");
		}

		while ((len = read(st.tempfd, buf, sizeof(buf))) > 0)
		{
			if (write(st.filefd, buf, len) != len)
			{
				close(st.tempfd);
				close(st.filefd);
				return response(false, "I/O failure while writing target file");
			}
		}

		close(st.filefd);
	}

	close(st.tempfd);

	if (chmod(st.filename, st.filemode))
		return response(false, "Failed to chmod target file");

	return 0;
}

static int
header_field(multipart_parser *p, const char *data, size_t len)
{
	st.is_content_disposition = !strncasecmp(data, "Content-Disposition", len);
	return 0;
}

static int
header_value(multipart_parser *p, const char *data, size_t len)
{
	size_t i, j;

	if (!st.is_content_disposition)
		return 0;

	if (len < 10 || strncasecmp(data, "form-data", 9))
		return 0;

	for (data += 9, len -= 9; *data == ' ' || *data == ';'; data++, len--);

	if (len < 8 || strncasecmp(data, "name=\"", 6))
		return 0;

	for (data += 6, len -= 6, i = 0; i <= len; i++)
	{
		if (*(data + i) != '"')
			continue;

		for (j = 1; j < sizeof(parts) / sizeof(parts[0]); j++)
			if (!strncmp(data, parts[j], i))
				st.parttype = j;

		break;
	}

	return 0;
}

static int
data_begin_cb(multipart_parser *p)
{
	if (st.parttype == PART_FILEDATA)
	{
		if (!st.sessionid)
			return response(false, "File data without session");

		if (!st.filename)
			return response(false, "File data without name");

		if (!session_access(st.sessionid, "file", st.filename, "write"))
			return response(false, "Access to path denied by ACL");

		st.tempfd = open("/tmp", O_TMPFILE | O_RDWR, S_IRUSR | S_IWUSR);

		if (st.tempfd < 0)
			return response(false, "Failed to create temporary file");
	}

	return 0;
}

static int
data_cb(multipart_parser *p, const char *data, size_t len)
{
	int wlen = len;

	switch (st.parttype)
	{
	case PART_SESSIONID:
		st.sessionid = datadup(data, len);
		break;

	case PART_FILENAME:
		st.filename = canonicalize_path(data, len);
		break;

	case PART_FILEMODE:
		st.filemode = strtoul(data, NULL, 8);
		break;

	case PART_FILEDATA:
		if (write(st.tempfd, data, len) != wlen)
		{
			close(st.tempfd);
			return response(false, "I/O failure while writing temporary file");
		}

		if (!st.filedata)
			st.filedata = !!wlen;

		break;

	default:
		break;
	}

	return 0;
}

static int
data_end_cb(multipart_parser *p)
{
	if (st.parttype == PART_SESSIONID)
	{
		if (!session_access(st.sessionid, "cgi-io", "upload", "write"))
		{
			errno = EPERM;
			return response(false, "Upload permission denied");
		}
	}
	else if (st.parttype == PART_FILEDATA)
	{
		if (st.tempfd < 0)
			return response(false, "Internal program failure");

#if 0
		/* prepare directory */
		for (ptr = st.filename; *ptr; ptr++)
		{
			if (*ptr == '/')
			{
				*ptr = 0;

				if (mkdir(st.filename, 0755))
				{
					unlink(st.tmpname);
					return response(false, "Failed to create destination directory");
				}

				*ptr = '/';
			}
		}
#endif

		if (filecopy())
			return -1;

		return response(true, NULL);
	}

	st.parttype = PART_UNKNOWN;
	return 0;
}

static multipart_parser *
init_parser(void)
{
	char *boundary;
	const char *var;

	multipart_parser *p;
	static multipart_parser_settings s = {
		.on_part_data        = data_cb,
		.on_headers_complete = data_begin_cb,
		.on_part_data_end    = data_end_cb,
		.on_header_field     = header_field,
		.on_header_value     = header_value
	};

	var = getenv("CONTENT_TYPE");

	if (!var || strncmp(var, "multipart/form-data;", 20))
		return NULL;

	for (var += 20; *var && *var != '='; var++);

	if (*var++ != '=')
		return NULL;

	boundary = malloc(strlen(var) + 3);

	if (!boundary)
		return NULL;

	strcpy(boundary, "--");
	strcpy(boundary + 2, var);

	st.tempfd = -1;
	st.filefd = -1;
	st.filemode = 0600;

	p = multipart_parser_init(boundary, &s);

	free(boundary);

	return p;
}

static int
main_upload(int argc, char *argv[])
{
	int rem, len;
	bool done = false;
	char buf[READ_BLOCK];
	multipart_parser *p;

	p = init_parser();

	if (!p)
	{
		errno = EINVAL;
		return response(false, "Invalid request");
	}

	while ((len = read(0, buf, sizeof(buf))) > 0)
	{
		if (!done) {
			rem = multipart_parser_execute(p, buf, len);
			done = (rem < len);
		}
	}

	multipart_parser_free(p);

	return 0;
}

static void
free_charp(char **ptr)
{
	free(*ptr);
}

#define autochar __attribute__((__cleanup__(free_charp))) char

static int
main_download(int argc, char **argv)
{
	char *fields[] = { "sessionid", NULL, "path", NULL, "filename", NULL, "mimetype", NULL };
	unsigned long long size = 0;
	char *p, buf[READ_BLOCK];
	ssize_t len = 0;
	struct stat s;
	int rfd;

	autochar *post = postdecode(fields, 4);

	if (!fields[1] || !session_access(fields[1], "cgi-io", "download", "read"))
		return failure(403, 0, "Download permission denied");

	if (!fields[3] || !session_access(fields[1], "file", fields[3], "read"))
		return failure(403, 0, "Access to path denied by ACL");

	if (stat(fields[3], &s))
		return failure(404, errno, "Failed to stat requested path");

	if (!S_ISREG(s.st_mode) && !S_ISBLK(s.st_mode))
		return failure(403, 0, "Requested path is not a regular file or block device");

	for (p = fields[5]; p && *p; p++)
		if (!isalnum(*p) && !strchr(" ()<>@,;:[]?.=%-", *p))
			return failure(400, 0, "Invalid characters in filename");

	for (p = fields[7]; p && *p; p++)
		if (!isalnum(*p) && !strchr(" .;=/-", *p))
			return failure(400, 0, "Invalid characters in mimetype");

	rfd = open(fields[3], O_RDONLY);

	if (rfd < 0)
		return failure(500, errno, "Failed to open requested path");

	if (S_ISBLK(s.st_mode))
		ioctl(rfd, BLKGETSIZE64, &size);
	else
		size = (unsigned long long)s.st_size;

	printf("Status: 200 OK\r\n");
	printf("Content-Type: %s\r\n", fields[7] ? fields[7] : "application/octet-stream");

	if (fields[5])
		printf("Content-Disposition: attachment; filename=\"%s\"\r\n", fields[5]);

	if (size > 0) {
		printf("Content-Length: %llu\r\n\r\n", size);
		fflush(stdout);

		while (size > 0) {
			len = sendfile(1, rfd, NULL, size);

			if (len == -1) {
				if (errno == ENOSYS || errno == EINVAL) {
					while ((len = read(rfd, buf, sizeof(buf))) > 0)
						fwrite(buf, len, 1, stdout);

					fflush(stdout);
					break;
				}

				if (errno == EINTR || errno == EAGAIN)
					continue;
			}

			if (len <= 0)
				break;

			size -= len;
		}
	}
	else {
		printf("\r\n");

		while ((len = read(rfd, buf, sizeof(buf))) > 0)
			fwrite(buf, len, 1, stdout);

		fflush(stdout);
	}

	close(rfd);

	return 0;
}

static int
main_backup(int argc, char **argv)
{
	pid_t pid;
	time_t now;
	int r;
	int len;
	int status;
	int fds[2];
	char datestr[16] = { 0 };
	char hostname[64] = { 0 };
	char *fields[] = { "sessionid", NULL };

	autochar *post = postdecode(fields, 1);

	if (!fields[1] || !session_access(fields[1], "cgi-io", "backup", "read"))
		return failure(403, 0, "Backup permission denied");

	if (pipe(fds))
		return failure(500, errno, "Failed to spawn pipe");

	switch ((pid = fork()))
	{
	case -1:
		return failure(500, errno, "Failed to fork process");

	case 0:
		dup2(fds[1], 1);

		close(0);
		close(2);
		close(fds[0]);
		close(fds[1]);

		r = chdir("/");
		if (r < 0)
			return failure(500, errno, "Failed chdir('/')");

		execl("/sbin/sysupgrade", "/sbin/sysupgrade",
		      "--create-backup", "-", NULL);

		return -1;

	default:
		close(fds[1]);

		now = time(NULL);
		strftime(datestr, sizeof(datestr) - 1, "%Y-%m-%d", localtime(&now));

		if (gethostname(hostname, sizeof(hostname) - 1))
			sprintf(hostname, "OpenWrt");

		printf("Status: 200 OK\r\n");
		printf("Content-Type: application/x-targz\r\n");
		printf("Content-Disposition: attachment; "
		       "filename=\"backup-%s-%s.tar.gz\"\r\n\r\n", hostname, datestr);

		fflush(stdout);

		do {
			len = splice(fds[0], NULL, 1, NULL, READ_BLOCK, SPLICE_F_MORE);
		} while (len > 0);

		waitpid(pid, &status, 0);

		close(fds[0]);

		return 0;
	}
}


static const char *
lookup_executable(const char *cmd)
{
	size_t plen = 0, clen = strlen(cmd) + 1;
	static char path[PATH_MAX];
	char *search, *p;
	struct stat s;

	if (!stat(cmd, &s) && S_ISREG(s.st_mode))
		return cmd;

	search = getenv("PATH");

	if (!search)
		search = "/bin:/usr/bin:/sbin:/usr/sbin";

	p = search;

	do {
		if (*p != ':' && *p != '\0')
			continue;

		plen = p - search;

		if ((plen + clen) >= sizeof(path))
			continue;

		strncpy(path, search, plen);
		sprintf(path + plen, "/%s", cmd);

		if (!stat(path, &s) && S_ISREG(s.st_mode))
			return path;

		search = p + 1;
	} while (*p++);

	return NULL;
}

static char **
parse_command(const char *cmdline)
{
	const char *p = cmdline, *s;
	char **argv = NULL, *out;
	size_t arglen = 0;
	int argnum = 0;
	bool esc;

	while (isspace(*cmdline))
		cmdline++;

	for (p = cmdline, s = p, esc = false; p; p++) {
		if (esc) {
			esc = false;
		}
		else if (*p == '\\' && p[1] != 0) {
			esc = true;
		}
		else if (isspace(*p) || *p == 0) {
			if (p > s) {
				argnum += 1;
				arglen += sizeof(char *) + (p - s) + 1;
			}

			s = p + 1;
		}

		if (*p == 0)
			break;
	}

	if (arglen == 0)
		return NULL;

	argv = calloc(1, arglen + sizeof(char *));

	if (!argv)
		return NULL;

	out = (char *)argv + sizeof(char *) * (argnum + 1);
	argv[0] = out;

	for (p = cmdline, s = p, esc = false, argnum = 0; p; p++) {
		if (esc) {
			esc = false;
			*out++ = *p;
		}
		else if (*p == '\\' && p[1] != 0) {
			esc = true;
		}
		else if (isspace(*p) || *p == 0) {
			if (p > s) {
				*out++ = ' ';
				argv[++argnum] = out;
			}

			s = p + 1;
		}
		else {
			*out++ = *p;
		}

		if (*p == 0)
			break;
	}

	argv[argnum] = NULL;
	out[-1] = 0;

	return argv;
}

static int
main_exec(int argc, char **argv)
{
	char *fields[] = { "sessionid", NULL, "command", NULL, "filename", NULL, "mimetype", NULL };
	int i, devnull, status, fds[2];
	bool allowed = false;
	ssize_t len = 0;
	const char *exe;
	char *p, **args;
	pid_t pid;

	autochar *post = postdecode(fields, 4);

	if (!fields[1] || !session_access(fields[1], "cgi-io", "exec", "read"))
		return failure(403, 0, "Exec permission denied");

	for (p = fields[5]; p && *p; p++)
		if (!isalnum(*p) && !strchr(" ()<>@,;:[]?.=%-", *p))
			return failure(400, 0, "Invalid characters in filename");

	for (p = fields[7]; p && *p; p++)
		if (!isalnum(*p) && !strchr(" .;=/-", *p))
			return failure(400, 0, "Invalid characters in mimetype");

	args = fields[3] ? parse_command(fields[3]) : NULL;

	if (!args)
		return failure(400, 0, "Invalid command parameter");

	/* First check if we find an ACL match for the whole cmdline ... */
	allowed = session_access(fields[1], "file", args[0], "exec");

	/* Now split the command vector... */
	for (i = 1; args[i]; i++)
		args[i][-1] = 0;

	/* Find executable... */
	exe = lookup_executable(args[0]);

	if (!exe) {
		free(args);
		return failure(404, 0, "Executable not found");
	}

	/* If there was no ACL match, check for a match on the executable */
	if (!allowed && !session_access(fields[1], "file", exe, "exec")) {
		free(args);
		return failure(403, 0, "Access to command denied by ACL");
	}

	if (pipe(fds)) {
		free(args);
		return failure(500, errno, "Failed to spawn pipe");
	}

	switch ((pid = fork()))
	{
	case -1:
		free(args);
		close(fds[0]);
		close(fds[1]);
		return failure(500, errno, "Failed to fork process");

	case 0:
		devnull = open("/dev/null", O_RDWR);

		if (devnull > -1) {
			dup2(devnull, 0);
			dup2(devnull, 2);
			close(devnull);
		}
		else {
			close(0);
			close(2);
		}

		dup2(fds[1], 1);
		close(fds[0]);
		close(fds[1]);

		if (chdir("/") < 0) {
			free(args);
			return failure(500, errno, "Failed chdir('/')");
		}

		if (execv(exe, args) < 0) {
			free(args);
			return failure(500, errno, "Failed execv(...)");
		}

		return -1;

	default:
		close(fds[1]);

		printf("Status: 200 OK\r\n");
		printf("Content-Type: %s\r\n",
		       fields[7] ? fields[7] : "application/octet-stream");

		if (fields[5])
			printf("Content-Disposition: attachment; filename=\"%s\"\r\n",
			       fields[5]);

		printf("\r\n");
		fflush(stdout);

		do {
			len = splice(fds[0], NULL, 1, NULL, READ_BLOCK, SPLICE_F_MORE);
		} while (len > 0);

		waitpid(pid, &status, 0);

		close(fds[0]);
		free(args);

		return 0;
	}
}

int main(int argc, char **argv)
{
	if (strstr(argv[0], "cgi-upload"))
		return main_upload(argc, argv);
	else if (strstr(argv[0], "cgi-download"))
		return main_download(argc, argv);
	else if (strstr(argv[0], "cgi-backup"))
		return main_backup(argc, argv);
	else if (strstr(argv[0], "cgi-exec"))
		return main_exec(argc, argv);

	return -1;
}
