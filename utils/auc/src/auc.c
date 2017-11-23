/*
 * auc - attendedsysUpgrade CLI
 * Copyright (C) 2017 Daniel Golle <daniel@makrotopia.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3
 * as published by the Free Software Foundation
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

#define _GNU_SOURCE
#define AUC_VERSION "0.0.3"

#include <fcntl.h>
#include <dlfcn.h>
#include <glob.h>
#include <stdio.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>

#include <uci.h>
#include <uci_blob.h>
#include <json-c/json.h>
#include <libubox/ulog.h>
#include <libubox/list.h>
#include <libubox/vlist.h>
#include <libubox/blobmsg_json.h>
#include <libubox/avl-cmp.h>
#include <libubox/uclient.h>
#include <libubox/uclient-utils.h>
#include <libubus.h>

#define REQ_TIMEOUT 15
#define APIOBJ_CHECK "api/upgrade-check"
#define APIOBJ_REQUEST "api/upgrade-request"

static char user_agent[80];
static char *serverurl;
static int upgrade_packages;
static struct ustream_ssl_ctx *ssl_ctx;
static const struct ustream_ssl_ops *ssl_ops;
static off_t out_bytes;
static off_t out_len;
static off_t out_offset;
static bool cur_resume;
static int output_fd = -1;
static int retry, imagebuilder, building;
static char *board_name = NULL;
static char *target = NULL, *subtarget = NULL;
static char *distribution = NULL, *version = NULL, *revision = NULL;
static int uptodate;
static char *filename = NULL;
static int debug = 0;

/*
 * policy for ubus call system board
 * see procd/system.c
 */
enum {
	BOARD_KERNEL,
	BOARD_HOSTNAME,
	BOARD_SYSTEM,
	BOARD_MODEL,
	BOARD_BOARD_NAME,
	BOARD_RELEASE,
	__BOARD_MAX,
};

static const struct blobmsg_policy board_policy[__BOARD_MAX] = {
	[BOARD_KERNEL] = { .name = "kernel", .type = BLOBMSG_TYPE_STRING },
	[BOARD_HOSTNAME] = { .name = "hostname", .type = BLOBMSG_TYPE_STRING },
	[BOARD_SYSTEM] = { .name = "system", .type = BLOBMSG_TYPE_STRING },
	[BOARD_MODEL] = { .name = "model", .type = BLOBMSG_TYPE_STRING },
	[BOARD_BOARD_NAME] = { .name = "board_name", .type = BLOBMSG_TYPE_STRING },
	[BOARD_RELEASE] = { .name = "release", .type = BLOBMSG_TYPE_TABLE },
};

/*
 * policy for release information in system board reply
 * see procd/system.c
 */
enum {
	RELEASE_DISTRIBUTION,
	RELEASE_VERSION,
	RELEASE_REVISION,
	RELEASE_CODENAME,
	RELEASE_TARGET,
	RELEASE_DESCRIPTION,
	__RELEASE_MAX,
};

static const struct blobmsg_policy release_policy[__RELEASE_MAX] = {
	[RELEASE_DISTRIBUTION] = { .name = "distribution", .type = BLOBMSG_TYPE_STRING },
	[RELEASE_VERSION] = { .name = "version", .type = BLOBMSG_TYPE_STRING },
	[RELEASE_REVISION] = { .name = "revision", .type = BLOBMSG_TYPE_STRING },
	[RELEASE_CODENAME] = { .name = "codename", .type = BLOBMSG_TYPE_STRING },
	[RELEASE_TARGET] = { .name = "target", .type = BLOBMSG_TYPE_STRING },
	[RELEASE_DESCRIPTION] = { .name = "description", .type = BLOBMSG_TYPE_STRING },
};

/*
 * policy for packagelist
 * see rpcd/sys.c
 */
enum {
	PACKAGELIST_PACKAGES,
	__PACKAGELIST_MAX,
};

static const struct blobmsg_policy packagelist_policy[__PACKAGELIST_MAX] = {
	[PACKAGELIST_PACKAGES] = { .name = "packages", .type = BLOBMSG_TYPE_TABLE },
};

/*
 * policy for upgrade_test
 * see rpcd/sys.c
 */
enum {
	UPGTEST_CODE,
	UPGTEST_STDOUT,
	__UPGTEST_MAX,
};

static const struct blobmsg_policy upgtest_policy[__UPGTEST_MAX] = {
	[UPGTEST_CODE] = { .name = "code", .type = BLOBMSG_TYPE_INT32 },
	[UPGTEST_STDOUT] = { .name = "stdout", .type = BLOBMSG_TYPE_STRING },
};


/*
 * policy to extract version from upgrade-check response
 */
enum {
	CHECK_VERSION,
	CHECK_UPGRADES,
	__CHECK_MAX,
};

static const struct blobmsg_policy check_policy[__CHECK_MAX] = {
	[CHECK_VERSION] = { .name = "version", .type = BLOBMSG_TYPE_STRING },
	[CHECK_UPGRADES] = { .name = "upgrades", .type = BLOBMSG_TYPE_TABLE },
};

/*
 * policy for upgrade-request response
 * parse download information for the ready image.
 */
enum {
	IMAGE_FILESIZE,
	IMAGE_URL,
	IMAGE_CHECKSUM,
	IMAGE_FILES,
	IMAGE_SYSUPGRADE,
	__IMAGE_MAX,
};

static const struct blobmsg_policy image_policy[__IMAGE_MAX] = {
	[IMAGE_FILESIZE] = { .name = "filesize", .type = BLOBMSG_TYPE_INT32 },
	[IMAGE_URL] = { .name = "url", .type = BLOBMSG_TYPE_STRING },
	[IMAGE_CHECKSUM] = { .name = "checksum", .type = BLOBMSG_TYPE_STRING },
	[IMAGE_FILES] = { .name = "files", .type = BLOBMSG_TYPE_STRING },
	[IMAGE_SYSUPGRADE] = { .name = "sysupgrade", .type = BLOBMSG_TYPE_STRING },
};


/*
 * load serverurl from UCI
 */
static int load_config() {
	static struct uci_context *uci_ctx;
	static struct uci_package *uci_attendedsysupgrade;
	struct uci_section *uci_s;

	uci_ctx = uci_alloc_context();
	if (!uci_ctx)
		return -1;

	uci_ctx->flags &= ~UCI_FLAG_STRICT;

	if (uci_load(uci_ctx, "attendedsysupgrade", &uci_attendedsysupgrade) ||
	    !uci_attendedsysupgrade) {
		fprintf(stderr, "Failed to load attendedsysupgrade config\n");
		return -1;
	}

	uci_s = uci_lookup_section(uci_ctx, uci_attendedsysupgrade, "server");
	if (!uci_s) {
		fprintf(stderr, "Failed to read server url from config\n");
		return -1;
	}
	serverurl = strdup(uci_lookup_option_string(uci_ctx, uci_s, "url"));

	uci_s = uci_lookup_section(uci_ctx, uci_attendedsysupgrade, "client");
	if (!uci_s) {
		fprintf(stderr, "Failed to read client config\n");
		return -1;
	}
	upgrade_packages = atoi(uci_lookup_option_string(uci_ctx, uci_s, "upgrade_packages"));

	uci_free_context(uci_ctx);

	return 0;
}


/**
 * UBUS response callbacks
 */

/*
 * rpc-sys packagelist
 * append packagelist response to blobbuf given in req->priv
 */
static void pkglist_cb(struct ubus_request *req, int type, struct blob_attr *msg) {
	struct blob_buf *buf = (struct blob_buf *)req->priv;
	struct blob_attr *tb[__PACKAGELIST_MAX];

	blobmsg_parse(packagelist_policy, __PACKAGELIST_MAX, tb, blob_data(msg), blob_len(msg));

	if (!tb[PACKAGELIST_PACKAGES]) {
		fprintf(stderr, "No packagelist received\n");
		return;
	}

	blobmsg_add_field(buf, BLOBMSG_TYPE_TABLE, "packages", blobmsg_data(tb[PACKAGELIST_PACKAGES]), blobmsg_data_len(tb[PACKAGELIST_PACKAGES]));
};

/*
 * system board
 * append append board information to blobbuf given in req->priv
 * populate board and release global strings
 */
static void board_cb(struct ubus_request *req, int type, struct blob_attr *msg) {
	struct blob_buf *buf = (struct blob_buf *)req->priv;
	struct blob_attr *tb[__BOARD_MAX];
	struct blob_attr *rel[__RELEASE_MAX];

	blobmsg_parse(board_policy, __BOARD_MAX, tb, blob_data(msg), blob_len(msg));

	if (!tb[BOARD_BOARD_NAME]) {
		fprintf(stderr, "No board name received\n");
		return;
	}
	board_name = strdup(blobmsg_get_string(tb[BOARD_BOARD_NAME]));

	if (!tb[BOARD_RELEASE]) {
		fprintf(stderr, "No release received\n");
		return;
	}

	blobmsg_parse(release_policy, __RELEASE_MAX, rel,
			blobmsg_data(tb[BOARD_RELEASE]), blobmsg_data_len(tb[BOARD_RELEASE]));

	if (!rel[RELEASE_TARGET]) {
		fprintf(stderr, "No target received\n");
		return;
	}

	target = strdup(blobmsg_get_string(rel[RELEASE_TARGET]));
	subtarget = strchr(target, '/');
	*subtarget++ = '\0';

	distribution = strdup(blobmsg_get_string(rel[RELEASE_DISTRIBUTION]));
	version = strdup(blobmsg_get_string(rel[RELEASE_VERSION]));
	revision = strdup(blobmsg_get_string(rel[RELEASE_REVISION]));

	blobmsg_add_string(buf, "distro", distribution);
	blobmsg_add_string(buf, "target", target);
	blobmsg_add_string(buf, "subtarget", subtarget);
	blobmsg_add_string(buf, "version", version);
}

/*
 * rpc-sys upgrade_test
 * check if downloaded file is accepted by sysupgrade
 */
static void upgtest_cb(struct ubus_request *req, int type, struct blob_attr *msg) {
	int *valid = (int *)req->priv;
	struct blob_attr *tb[__UPGTEST_MAX];

	blobmsg_parse(upgtest_policy, __UPGTEST_MAX, tb, blob_data(msg), blob_len(msg));

	if (!tb[UPGTEST_CODE]) {
		fprintf(stderr, "No sysupgrade test return code received\n");
		return;
	}

	*valid = (blobmsg_get_u32(tb[UPGTEST_CODE]) == 0)?1:0;
	if (*valid == 0)
		fprintf(stderr, "%s", blobmsg_get_string(tb[UPGTEST_STDOUT]));
};

/**
 * uclient stuff
 */
static int open_output_file(const char *path, uint64_t resume_offset)
{
	char *filename = NULL;
	int flags;
	int ret;

	if (cur_resume)
		flags = O_RDWR;
	else
		flags = O_WRONLY | O_EXCL;

	flags |= O_CREAT;

	filename = uclient_get_url_filename(path, "firmware.bin");

	fprintf(stderr, "Writing to '%s'\n", filename);
	ret = open(filename, flags, 0644);
	if (ret < 0)
		goto free;

	if (resume_offset &&
	    lseek(ret, resume_offset, SEEK_SET) < 0) {
		fprintf(stderr, "Failed to seek %"PRIu64" bytes in output file\n", resume_offset);
		close(ret);
		ret = -1;
		goto free;
	}

	out_offset = resume_offset;
	out_bytes += resume_offset;

free:
	free(filename);
	return ret;
}

static void request_done(struct uclient *cl)
{
	uclient_disconnect(cl);
	uloop_end();
}

static void header_done_cb(struct uclient *cl)
{
	enum {
		H_RANGE,
		H_LEN,
		H_IBSTATUS,
		H_IBQUEUEPOS,
		__H_MAX
	};
	static const struct blobmsg_policy policy[__H_MAX] = {
		[H_RANGE] = { .name = "content-range", .type = BLOBMSG_TYPE_STRING },
		[H_LEN] = { .name = "content-length", .type = BLOBMSG_TYPE_STRING },
		[H_IBSTATUS] = { .name = "x-imagebuilder-status", .type = BLOBMSG_TYPE_STRING },
		[H_IBQUEUEPOS] = { .name = "x-build-queue-position", .type = BLOBMSG_TYPE_STRING },
	};
	struct blob_attr *tb[__H_MAX];
	uint64_t resume_offset = 0, resume_end, resume_size;
	char *ibstatus;
	unsigned int queuepos = 0;

	if (uclient_http_redirect(cl)) {
		fprintf(stderr, "Redirected to %s on %s\n", cl->url->location, cl->url->host);

		return;
	}

	if (cl->status_code == 204 && cur_resume) {
		/* Resume attempt failed, try normal download */
		cur_resume = false;
		//init_request(cl);
		return;
	}

	if (debug)
		fprintf(stderr, "headers:\n%s\n", blobmsg_format_json_indent(cl->meta, true, 0));

	blobmsg_parse(policy, __H_MAX, tb, blob_data(cl->meta), blob_len(cl->meta));

	switch (cl->status_code) {
	case 400:
		request_done(cl);
		break;
	case 412:
		fprintf(stderr, "target not found.\n");
		request_done(cl);
		break;
	case 413:
		fprintf(stderr, "image too big.\n");
		request_done(cl);
		break;
	case 416:
		fprintf(stderr, "File download already fully retrieved; nothing to do.\n");
		request_done(cl);
		break;
	case 422:
		fprintf(stderr, "unknown package requested.\n");
		request_done(cl);
		break;
	case 501:
		fprintf(stderr, "ImageBuilder didn't produce sysupgrade file.\n");
		request_done(cl);
		break;
	case 204:
		fprintf(stderr, "system is up to date.\n");
		uptodate=1;
		break;
	case 206:
		if (!cur_resume) {
			fprintf(stderr, "Error: Partial content received, full content requested\n");
			request_done(cl);
			break;
		}

		if (!tb[H_RANGE]) {
			fprintf(stderr, "Content-Range header is missing\n");
			break;
		}

		if (sscanf(blobmsg_get_string(tb[H_RANGE]),
			   "bytes %"PRIu64"-%"PRIu64"/%"PRIu64,
			   &resume_offset, &resume_end, &resume_size) != 3) {
			fprintf(stderr, "Content-Range header is invalid\n");
			break;
		}
	case 202:
		if (!tb[H_IBSTATUS])
			break;

		ibstatus = blobmsg_get_string(tb[H_IBSTATUS]);

		if (!strncmp(ibstatus, "queue", 6)) {
			if (!imagebuilder) {
				fprintf(stderr, "server is dispatching build job\n");
				imagebuilder=1;
			} else {
				if (tb[H_IBQUEUEPOS]) {
					queuepos = atoi(blobmsg_get_string(tb[H_IBQUEUEPOS]));
					fprintf(stderr, "build is in queue position %u.\n", queuepos);
				}
			}
			retry=1;
		} else if (!strncmp(ibstatus, "building", 9)) {
			if (!building) {
				fprintf(stderr, "server is now building image...\n");
				building=1;
			}
			retry=1;
		} else {
			fprintf(stderr, "unrecognized remote imagebuilder status '%s'\n", ibstatus);
		}
		// fall through
	case 200:
		if (cl->priv)
			break;

		if (tb[H_LEN])
			out_len = strtoul(blobmsg_get_string(tb[H_LEN]), NULL, 10);

		output_fd = open_output_file(cl->url->location, resume_offset);
		if (output_fd < 0) {
			perror("Cannot open output file");
			request_done(cl);
		}
		break;

	default:
		fprintf(stderr, "HTTP error %d\n", cl->status_code);
		request_done(cl);
		break;
	}
}

static void read_data_cb(struct uclient *cl)
{
	char buf[256];
	int len;
	json_tokener *tok;
	json_object *jsobj;

	struct blob_buf *outbuf = (struct blob_buf *)cl->priv;

	if (!outbuf) {
		while (1) {
			len = uclient_read(cl, buf, sizeof(buf));
			if (!len)
				return;

			out_bytes += len;
			write(output_fd, buf, len);
		}
		return;
	}

	tok = json_tokener_new();
	
	while (1) {
		len = uclient_read(cl, buf, sizeof(buf));
		if (!len)
			break;

		out_bytes += len;

		jsobj = json_tokener_parse_ex(tok, buf, len);

		if (json_tokener_get_error(tok) == json_tokener_continue)
			continue;

		if (json_tokener_get_error(tok) != json_tokener_success)
			break;

		if (jsobj)
		{
			if (json_object_get_type(jsobj) == json_type_object)
				blobmsg_add_object(outbuf, jsobj);

			json_object_put(jsobj);
			break;
		}
	}

	json_tokener_free(tok);
}

static void eof_cb(struct uclient *cl)
{
	if (!cl->data_eof && !uptodate) {
		fprintf(stderr, "Connection reset prematurely\n");
	}
	request_done(cl);
}

static void handle_uclient_error(struct uclient *cl, int code)
{
	const char *type = "Unknown error";

	switch(code) {
	case UCLIENT_ERROR_CONNECT:
		type = "Connection failed";
		break;
	case UCLIENT_ERROR_TIMEDOUT:
		type = "Connection timed out";
		break;
	case UCLIENT_ERROR_SSL_INVALID_CERT:
		type = "Invalid SSL certificate";
		break;
	case UCLIENT_ERROR_SSL_CN_MISMATCH:
		type = "Server hostname does not match SSL certificate";
		break;
	default:
		break;
	}

	fprintf(stderr, "Connection error: %s\n", type);

	request_done(cl);
}

static const struct uclient_cb check_cb = {
	.header_done = header_done_cb,
	.data_read = read_data_cb,
	.data_eof = eof_cb,
	.error = handle_uclient_error,
};

static int server_request(const char *url, struct blob_buf *inbuf, struct blob_buf *outbuf) {
	struct uclient *ucl;
	int rc = -1;
	char *post_data;
	out_offset = 0;
	out_bytes = 0;
	out_len = 0;

	uloop_init();

	ucl = uclient_new(url, NULL, &check_cb);
	uclient_http_set_ssl_ctx(ucl, ssl_ops, ssl_ctx, 1);
	ucl->timeout_msecs = REQ_TIMEOUT * 1000;
	ucl->priv = outbuf;
	rc = uclient_connect(ucl);
	if (rc)
		return rc;

	rc = uclient_http_set_request_type(ucl, inbuf?"POST":"GET");
	if (rc)
		return rc;

	uclient_http_reset_headers(ucl);
	uclient_http_set_header(ucl, "User-Agent", user_agent);
	if (inbuf) {
		uclient_http_set_header(ucl, "Content-Type", "text/json");
		post_data = blobmsg_format_json(inbuf->head, true);
		uclient_write(ucl, post_data, strlen(post_data));
	}
	rc = uclient_request(ucl);
	if (rc)
		return rc;

	uloop_run();
	uloop_done();
	uclient_free(ucl);

	return 0;
}

/**
 * ustream-ssl
 */
static int init_ustream_ssl(void) {
	void *dlh;
	glob_t gl;
	int i;

	dlh = dlopen("libustream-ssl.so", RTLD_LAZY | RTLD_LOCAL);
	if (!dlh)
		return -1;

	ssl_ops = dlsym(dlh, "ustream_ssl_ops");
	if (!ssl_ops)
		return -1;

	ssl_ctx = ssl_ops->context_new(false);

	glob("/etc/ssl/certs/*.crt", 0, NULL, &gl);
	if (!gl.gl_pathc)
		return -2;

	for (i = 0; i < gl.gl_pathc; i++)
		ssl_ops->context_add_ca_crt_file(ssl_ctx, gl.gl_pathv[i]);

	return 0;
}

/**
 * use busybox md5sum (from jow's luci-ng)
 */
static char *md5sum(const char *file) {
	pid_t pid;
	int fds[2];
	static char md5[33];

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

		if (execl("/bin/busybox", "/bin/busybox", "md5sum", file, NULL));
			return NULL;

		break;

	default:
		memset(md5, 0, sizeof(md5));
		read(fds[0], md5, 32);
		waitpid(pid, NULL, 0);
		close(fds[0]);
		close(fds[1]);
	}

	return md5;
}

static int ask_user(void)
{
	fprintf(stderr, "Are you sure to proceed? [N/y]\n");
	if (getchar() != 'y')
		return -1;
	return 0;
}

/* this main function is too big... todo: split */
int main(int args, char *argv[]) {
	static struct blob_buf checkbuf, reqbuf, imgbuf, upgbuf;
	struct ubus_context *ctx = ubus_connect(NULL);
	uint32_t id;
	int rc;
	int queuepos, valid;
	char url[256];
	char *newversion = NULL;
	struct blob_attr *tb[__IMAGE_MAX];
	struct blob_attr *tbc[__CHECK_MAX];
	unsigned int filesize;
	char *checksum = NULL;
	struct stat imgstat;

	if (args>1 && !strncmp(argv[1], "-d", 3))
		debug = 1;

	if (!ctx) {
		fprintf(stderr, "failed to connect to ubus.\n");
		return -1;
	}
	if (load_config()) {
		rc=-1;
		goto freeubus;
	}

	if (chdir("/tmp")) {
		rc=-1;
		goto freeconfig;
	}

	rc = init_ustream_ssl();
	if (rc == -2) {
		fprintf(stderr, "No CA certificates loaded, please install ca-certificates\n");
		rc=-1;
		goto freessl;
	}

	if (rc || !ssl_ctx) {
		fprintf(stderr, "SSL support not available, please install ustream-ssl\n");
		rc=-1;
		goto freessl;
	}

	blobmsg_buf_init(&checkbuf);
	blobmsg_buf_init(&reqbuf);
	blobmsg_buf_init(&imgbuf);
	blobmsg_buf_init(&upgbuf);

	snprintf(user_agent, sizeof(user_agent), "%s (%s)", argv[0], AUC_VERSION);

	fprintf(stderr, "%s\n", user_agent);

	if (ubus_lookup_id(ctx, "system", &id) ||
	    ubus_invoke(ctx, id, "board", NULL, board_cb, &checkbuf, 3000)) {
		fprintf(stderr, "cannot request board info from procd\n");
		rc=-1;
		goto freebufs;
	}

	if (ubus_lookup_id(ctx, "rpc-sys", &id) ||
	    ubus_invoke(ctx, id, "packagelist", NULL, pkglist_cb, &checkbuf, 3000)) {
		fprintf(stderr, "cannot request packagelist from rpcd\n");
		rc=-1;
		goto freeboard;
	}

	blobmsg_add_u32(&checkbuf, "upgrade_packages", upgrade_packages);

	fprintf(stderr, "running %s %s %s on %s/%s (%s)\n", distribution,
		version, revision, target, subtarget, board_name);

	fprintf(stderr, "checking %s for release upgrade%s\n", serverurl,
		upgrade_packages?" or updated packages":"");

	blobmsg_add_string(&reqbuf, "distro", distribution);
	blobmsg_add_string(&reqbuf, "target", target);
	blobmsg_add_string(&reqbuf, "subtarget", subtarget);
	blobmsg_add_string(&reqbuf, "board", board_name);

	snprintf(url, sizeof(url), "%s/%s", serverurl, APIOBJ_CHECK);
	uptodate=0;

	if (debug)
		fprintf(stderr, "requesting:\n%s\n", blobmsg_format_json_indent(checkbuf.head, true, 0));

	if (server_request(url, &checkbuf, &reqbuf)) {
		fprintf(stderr, "failed to connect to server\n");
		rc=-1;
		goto freeboard;
	};

	if (debug)
		fprintf(stderr, "reply:\n%s\n", blobmsg_format_json_indent(reqbuf.head, true, 0));

	blobmsg_parse(check_policy, __CHECK_MAX, tbc, blob_data(reqbuf.head), blob_len(reqbuf.head));

	if (!tbc[CHECK_VERSION] && !tbc[CHECK_UPGRADES]) {
		if (!uptodate) {
			fprintf(stderr, "server reply invalid.\n");
			rc=-1;
			goto freeboard;
		}
		rc=0;
		goto freeboard;
	}
	if (tbc[CHECK_VERSION]) {
		newversion = blobmsg_get_string(tbc[CHECK_VERSION]);
		fprintf(stderr, "new %s release %s found.\n", distribution, newversion);
	} else {
		fprintf(stderr, "staying on %s release version %s\n", distribution, version);
		blobmsg_add_string(&reqbuf, "version", version);
	};

	if (tbc[CHECK_UPGRADES]) {
		fprintf(stderr, "package updates found:\n%s\n",
			blobmsg_format_json_indent(tbc[CHECK_UPGRADES], true, 0));
	}
	rc = ask_user();
	if (rc)
		goto freeboard;

	snprintf(url, sizeof(url), "%s/%s", serverurl, APIOBJ_REQUEST);

	imagebuilder = 0;
	building = 0;

	do {
		retry = 0;

		if (debug)
			fprintf(stderr, "requesting:\n%s\n", blobmsg_format_json_indent(reqbuf.head, true, 0));

		server_request(url, &reqbuf, &imgbuf);
		blobmsg_parse(image_policy, __IMAGE_MAX, tb, blob_data(imgbuf.head), blob_len(imgbuf.head));

		if (retry) {
			blob_buf_free(&imgbuf);
			blobmsg_buf_init(&imgbuf);
			sleep(3);
		}
	} while(retry || queuepos);

	if (!tb[IMAGE_SYSUPGRADE]) {
		fprintf(stderr, "no sysupgrade image returned\n");
		rc=-1;
		goto freeboard;
	}
	strncpy(url, blobmsg_get_string(tb[IMAGE_SYSUPGRADE]), sizeof(url));

	if (!tb[IMAGE_FILESIZE]) {
		fprintf(stderr, "no image size returned\n");
		rc=-1;
		goto freeboard;
	}
	filesize = blobmsg_get_u32(tb[IMAGE_FILESIZE]);

	if (!tb[IMAGE_CHECKSUM]) {
		fprintf(stderr, "no image checksum returned\n");
		rc=-1;
		goto freeboard;
	}
	checksum = blobmsg_get_string(tb[IMAGE_CHECKSUM]);
	server_request(url, NULL, NULL);
/* usign signature is not yet implemented! */
//	strncat(url, ".sig", sizeof(url));
//	server_request(url, NULL, NULL);
	filename = uclient_get_url_filename(url, "firmware.bin");

	if (stat(filename, &imgstat)) {
		fprintf(stderr, "image download failed\n");
		rc=-1;
		goto freeboard;
	}

	if ((intmax_t)imgstat.st_size != filesize) {
		fprintf(stderr, "file size mismatch\n");
		unlink(filename);
		rc=-1;
		goto freeboard;
	}

	if (strncmp(checksum, md5sum(filename), 33)) {
		fprintf(stderr, "image checksum mismatch\n");
		unlink(filename);
		rc=-1;
		goto freeboard;
	};

	if (strcmp(filename, "firmware.bin")) {
		if (rename(filename, "firmware.bin")) {
			fprintf(stderr, "can't rename to firmware.bin\n");
			unlink(filename);
			rc=-1;
			goto freeboard;
		}
	}

	if (!ubus_lookup_id(ctx, "rpc-sys", &id)) {
		valid = 0;
		ubus_invoke(ctx, id, "upgrade_test", NULL, upgtest_cb, &valid, 3000);
		if (!valid) {
			rc=-1;
			goto freeboard;
		}

		blobmsg_add_u8(&upgbuf, "keep", 1);
		fprintf(stderr, "invoking sysupgrade\n");
		ubus_invoke(ctx, id, "upgrade_start", upgbuf.head, NULL, NULL, 3000);
	} else {
		rc=-1;
	}

freeboard:
	free(board_name);
	free(target);
	/* subtarget is a pointer within target, don't free */
	free(distribution);
	free(version);
	free(revision);

freebufs:
	blob_buf_free(&checkbuf);
	blob_buf_free(&reqbuf);
	blob_buf_free(&imgbuf);
	blob_buf_free(&upgbuf);

freessl:
	if (ssl_ctx)
		ssl_ops->context_free(ssl_ctx);

freeconfig:
	free(serverurl);

freeubus:
	ubus_free(ctx);

	return rc;
}
