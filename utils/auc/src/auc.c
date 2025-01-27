/*
 * auc - attendedsysUpgrade CLI
 * Copyright (C) 2017-2021 Daniel Golle <daniel@makrotopia.org>
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
#ifndef AUC_VERSION
#define AUC_VERSION "unknown"
#endif

#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <dlfcn.h>
#include <glob.h>
#include <stdio.h>
#include <time.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>
#include <stdbool.h>

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

#define API_BRANCHES "branches"
#define API_INDEX "index"
#define API_JSON "json"
#define API_JSON_VERSION "v1"
#define API_JSON_EXT "." API_JSON
#define API_PACKAGES "packages"
#define API_REQUEST "api/v1/build"
#define API_STATUS_QUEUED "queued"
#define API_STATUS_STARTED "started"
#define API_STORE "store"
#define API_TARGETS "targets"

#define PUBKEY_PATH "/etc/opkg/keys"
#define SHA256SUM "/bin/busybox sha256sum"

#ifdef AUC_DEBUG
#define DPRINTF(...) if (debug) fprintf(stderr, __VA_ARGS__)
#else
#define DPRINTF(...)
#endif

static const char server_issues[]="https://github.com/openwrt/asu/issues";

static struct ubus_context *ctx;
static struct uclient *ucl = NULL;
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
static bool retry = false;
static char *board_name = NULL;
static char *target = NULL;
static char *distribution = NULL, *version = NULL, *revision = NULL;
static char *rootfs_type = NULL;
static int uptodate;
static char *filename = NULL;
static void *dlh = NULL;
static int rc;
static bool dont_ask = false;

static int avl_verrevcmp(const void *k1, const void *k2, void *ptr);

struct branch {
	struct avl_node avl;
	char *name;
	char *git_branch;
	char *path_packages;
	char *arch_packages;
	char **repos;
	struct avl_tree versions;
	struct list_head package_changes;
	bool snapshot;
	unsigned int branch_off_rev;
};
static struct avl_tree branches = AVL_TREE_INIT(branches, avl_verrevcmp, false, NULL);

struct branch_version {
	struct avl_node avl;
	struct branch *branch;
	char *path;
	char *version;
	char *version_code;
	char *version_number;
	bool snapshot;
};

struct package_changes {
	struct list_head list;
	unsigned int revision;
	char *source;
	char *target;
	bool mandatory;
};
static LIST_HEAD(selected_package_changes);

struct avl_pkg {
	struct avl_node avl;
	char *name;
	char *version;
};
static struct avl_tree pkg_tree = AVL_TREE_INIT(pkg_tree, avl_strcmp, false, NULL);

#ifdef AUC_DEBUG
static int debug = 0;
#endif

/*
 * policy for ubus call system board
 * see procd/system.c
 */
enum {
	BOARD_BOARD_NAME,
	BOARD_RELEASE,
	BOARD_ROOTFS_TYPE,
	__BOARD_MAX,
};

static const struct blobmsg_policy board_policy[__BOARD_MAX] = {
	[BOARD_BOARD_NAME] = { .name = "board_name", .type = BLOBMSG_TYPE_STRING },
	[BOARD_RELEASE] = { .name = "release", .type = BLOBMSG_TYPE_TABLE },
	[BOARD_ROOTFS_TYPE] = { .name = "rootfs_type", .type = BLOBMSG_TYPE_STRING },
};

/*
 * policy for release information in system board reply
 * see procd/system.c
 */
enum {
	RELEASE_DISTRIBUTION,
	RELEASE_REVISION,
	RELEASE_TARGET,
	RELEASE_VERSION,
	__RELEASE_MAX,
};

static const struct blobmsg_policy release_policy[__RELEASE_MAX] = {
	[RELEASE_DISTRIBUTION] = { .name = "distribution", .type = BLOBMSG_TYPE_STRING },
	[RELEASE_REVISION] = { .name = "revision", .type = BLOBMSG_TYPE_STRING },
	[RELEASE_TARGET] = { .name = "target", .type = BLOBMSG_TYPE_STRING },
	[RELEASE_VERSION] = { .name = "version", .type = BLOBMSG_TYPE_STRING },
};

/*
 * policy for package list returned from rpc-sys or from server
 * see rpcd/sys.c and ASU sources
 */
enum {
	PACKAGES_ARCHITECTURE,
	PACKAGES_PACKAGES,
	__PACKAGES_MAX,
};

static const struct blobmsg_policy packages_policy[__PACKAGES_MAX] = {
	[PACKAGES_ARCHITECTURE] = { .name = "architecture", .type = BLOBMSG_TYPE_STRING },
	[PACKAGES_PACKAGES] = { .name = "packages", .type = BLOBMSG_TYPE_TABLE },
};

/*
 * policy for upgrade_test
 * see rpcd/sys.c
 */
enum {
	UPGTEST_CODE,
	UPGTEST_STDERR,
	__UPGTEST_MAX,
};

static const struct blobmsg_policy upgtest_policy[__UPGTEST_MAX] = {
	[UPGTEST_CODE] = { .name = "code", .type = BLOBMSG_TYPE_INT32 },
	[UPGTEST_STDERR] = { .name = "stderr", .type = BLOBMSG_TYPE_STRING },
};

/*
 * policy for branches.json
 */
enum {
	BRANCH_ENABLED,
	BRANCH_GIT_BRANCH,
	BRANCH_BRANCH_OFF_REV,
	BRANCH_NAME,
	BRANCH_PATH,
	BRANCH_PATH_PACKAGES,
	BRANCH_SNAPSHOT,
	BRANCH_REPOS,
	BRANCH_TARGETS,
	BRANCH_UPDATES,
	BRANCH_VERSIONS,
	BRANCH_PACKAGE_CHANGES,
	__BRANCH_MAX,
};

static const struct blobmsg_policy branches_policy[__BRANCH_MAX] = {
	[BRANCH_ENABLED] = { .name = "enabled", .type = BLOBMSG_TYPE_BOOL },
	[BRANCH_GIT_BRANCH] = { .name = "git_branch", .type = BLOBMSG_TYPE_STRING },
	[BRANCH_BRANCH_OFF_REV] = { .name = "branch_off_rev", .type = BLOBMSG_TYPE_INT32 },
	[BRANCH_NAME] = { .name = "name", .type = BLOBMSG_TYPE_STRING },
	[BRANCH_PATH] = { .name = "path", .type = BLOBMSG_TYPE_STRING },
	[BRANCH_PATH_PACKAGES] = { .name = "path_packages", .type = BLOBMSG_TYPE_STRING },
	[BRANCH_SNAPSHOT] = { .name = "snapshot", .type = BLOBMSG_TYPE_BOOL },
	[BRANCH_REPOS] = { .name = "repos", .type = BLOBMSG_TYPE_ARRAY },
	[BRANCH_TARGETS] = { .name = "targets", .type = BLOBMSG_TYPE_TABLE },
	[BRANCH_UPDATES] = { .name = "updates", .type = BLOBMSG_TYPE_STRING },
	[BRANCH_VERSIONS] = { .name = "versions", .type = BLOBMSG_TYPE_ARRAY },
	[BRANCH_PACKAGE_CHANGES] = { .name = "package_changes", .type = BLOBMSG_TYPE_ARRAY },
};

enum {
	PACKAGE_CHANGES_SOURCE,
	PACKAGE_CHANGES_TARGET,
	PACKAGE_CHANGES_REVISION,
	PACKAGE_CHANGES_MANDATORY,
	__PACKAGE_CHANGES_MAX,
};

static const struct blobmsg_policy package_changes_policy[__PACKAGE_CHANGES_MAX] = {
	[PACKAGE_CHANGES_SOURCE] = { .name = "source", .type = BLOBMSG_TYPE_STRING },
	[PACKAGE_CHANGES_TARGET] = { .name = "target", .type = BLOBMSG_TYPE_STRING },
	[PACKAGE_CHANGES_REVISION] = { .name = "revision", .type = BLOBMSG_TYPE_INT32 },
	[PACKAGE_CHANGES_MANDATORY] = { .name = "mandatory", .type = BLOBMSG_TYPE_BOOL },
};

/*
 * shared policy for target.json and server image request reply
 */
enum {
	TARGET_ARCH_PACKAGES,
	TARGET_BINDIR,
	TARGET_DEVICE_PACKAGES,
	TARGET_ENQUEUED_AT,
	TARGET_IMAGES,
	TARGET_DETAIL,
	TARGET_MANIFEST,
	TARGET_METADATA_VERSION,
	TARGET_REQUEST_HASH,
	TARGET_QUEUE_POSITION,
	TARGET_STATUS,
	TARGET_STDERR,
	TARGET_STDOUT,
	TARGET_TARGET,
	TARGET_TITLES,
	TARGET_VERSION_CODE,
	TARGET_VERSION_NUMBER,
	__TARGET_MAX,
};

static const struct blobmsg_policy target_policy[__TARGET_MAX] = {
	[TARGET_ARCH_PACKAGES] = { .name = "arch_packages", .type = BLOBMSG_TYPE_STRING },
	[TARGET_BINDIR] = { .name = "bin_dir", .type = BLOBMSG_TYPE_STRING },
	[TARGET_DEVICE_PACKAGES] = { .name = "device_packages", .type = BLOBMSG_TYPE_ARRAY },
	[TARGET_ENQUEUED_AT] = { .name = "enqueued_at", .type = BLOBMSG_TYPE_STRING },
	[TARGET_IMAGES] = { .name = "images", .type = BLOBMSG_TYPE_ARRAY },
	[TARGET_MANIFEST] = { .name = "manifest", .type = BLOBMSG_TYPE_TABLE },
	[TARGET_DETAIL] = { .name = "detail", .type = BLOBMSG_TYPE_STRING },
	[TARGET_METADATA_VERSION] = { .name = "metadata_version", .type = BLOBMSG_TYPE_INT32 },
	[TARGET_REQUEST_HASH] = { .name = "request_hash", .type = BLOBMSG_TYPE_STRING },
	[TARGET_QUEUE_POSITION] = { .name = "queue_position", .type = BLOBMSG_TYPE_INT32 },
	[TARGET_STATUS] = { .name = "status", .type = BLOBMSG_TYPE_STRING },
	[TARGET_STDERR] = { .name = "stderr", .type = BLOBMSG_TYPE_STRING },
	[TARGET_STDOUT] = { .name = "stdout", .type = BLOBMSG_TYPE_STRING },
	[TARGET_TARGET] = { .name = "target", .type = BLOBMSG_TYPE_STRING },
	[TARGET_TITLES] = { .name = "titles", .type = BLOBMSG_TYPE_ARRAY },
	[TARGET_VERSION_CODE] = { .name = "version_code", .type = BLOBMSG_TYPE_STRING },
	[TARGET_VERSION_NUMBER] = { .name = "version_number", .type = BLOBMSG_TYPE_STRING },
};

/*
 * policy for images object in target
 */
enum {
	IMAGES_FILESYSTEM,
	IMAGES_NAME,
	IMAGES_SHA256,
	IMAGES_TYPE,
	__IMAGES_MAX,
};

static const struct blobmsg_policy images_policy[__IMAGES_MAX] = {
	[IMAGES_FILESYSTEM] = { .name = "filesystem", .type = BLOBMSG_TYPE_STRING },
	[IMAGES_NAME] = { .name = "name", .type = BLOBMSG_TYPE_STRING },
	[IMAGES_SHA256] = { .name = "sha256", .type = BLOBMSG_TYPE_STRING },
	[IMAGES_TYPE] = { .name = "type", .type = BLOBMSG_TYPE_STRING },
};

/*
 * generic policy for HTTP JSON reply
 */
enum {
	REPLY_ARRAY,
	REPLY_OBJECT,
	__REPLY_MAX,
};

static const struct blobmsg_policy reply_policy[__REPLY_MAX] = {
	[REPLY_ARRAY] = { .name = "reply", .type = BLOBMSG_TYPE_ARRAY },
	[REPLY_OBJECT] = { .name = "reply", .type = BLOBMSG_TYPE_TABLE },
};

/*
 * policy for HTTP headers received from server
 */
enum {
	H_LEN,
	H_RANGE,
	H_UNKNOWN_PACKAGE,
	H_QUEUE_POSITION,
	__H_MAX
};

static const struct blobmsg_policy header_policy[__H_MAX] = {
	[H_LEN] = { .name = "content-length", .type = BLOBMSG_TYPE_STRING },
	[H_RANGE] = { .name = "content-range", .type = BLOBMSG_TYPE_STRING },
	[H_UNKNOWN_PACKAGE] = { .name = "x-unknown-package", .type = BLOBMSG_TYPE_STRING },
	[H_QUEUE_POSITION] = { .name = "x-queue-position", .type = BLOBMSG_TYPE_INT32 },
};

/*
 * load serverurl from UCI
 */
static int load_config() {
	struct uci_context *uci_ctx;
	struct uci_package *uci_attendedsysupgrade;
	struct uci_section *uci_s;
	char *url;

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
		fprintf(stderr, "Failed to read server config section\n");
		return -1;
	}
	url = uci_lookup_option_string(uci_ctx, uci_s, "url");
	if (!url) {
		fprintf(stderr, "Failed to read server url from config\n");
		return -1;
	}
	if (strncmp(url, "https://", strlen("https://")) &&
	    strncmp(url, "http://", strlen("http://"))) {
		fprintf(stderr, "Server url invalid (needs to be http://... or https://...)\n");
		return -1;
	}

	serverurl = strdup(url);

	uci_s = uci_lookup_section(uci_ctx, uci_attendedsysupgrade, "client");
	if (!uci_s) {
		fprintf(stderr, "Failed to read client config\n");
		return -1;
	}
	upgrade_packages = atoi(uci_lookup_option_string(uci_ctx, uci_s, "upgrade_packages"));

	uci_free_context(uci_ctx);

	return 0;
}

/*
 * libdpkg - Debian packaging suite library routines
 * vercmp.c - comparison of version numbers
 *
 * Copyright (C) 1995 Ian Jackson <iwj10@cus.cam.ac.uk>
 */

/* assume ascii; warning: evaluates x multiple times! */
#define order(x) ((x) == '~' ? -1 \
		: isdigit((x)) ? 0 \
		: !(x) ? 0 \
		: isalpha((x)) ? (x) \
		: (x) + 256)

static int verrevcmp(const char *val, const char *ref)
{
	if (!val)
		val = "";
	if (!ref)
		ref = "";

	while (*val || *ref) {
		int first_diff = 0;

		while ((*val && !isdigit(*val)) || (*ref && !isdigit(*ref))) {
			int vc = order(*val), rc = order(*ref);
			if (vc != rc)
				return vc - rc;
			val++;
			ref++;
		}

		while (*val == '0')
			val++;
		while (*ref == '0')
			ref++;
		while (isdigit(*val) && isdigit(*ref)) {
			if (!first_diff)
				first_diff = *val - *ref;
			val++;
			ref++;
		}
		if (isdigit(*val))
			return 1;
		if (isdigit(*ref))
			return -1;
		if (first_diff)
			return first_diff;
	}
	return 0;
}

static int avl_verrevcmp(const void *k1, const void *k2, void *ptr)
{
	const char *d1 = (const char *)k1, *d2 = (const char*)k2;

	return verrevcmp(d1, d2);
}

/*
 * replace '-rc' by '~' in string
 */
static inline void release_replace_rc(char *ver)
{
	char *tmp;

	tmp = strstr(ver, "-rc");
	if (tmp && strlen(tmp) > 3) {
		*tmp = '~';
		memmove(tmp + 1, tmp + 3, strlen(tmp + 3) + 1);
	}
}

/*
 * OpenWrt release version string comperator
 * replaces '-rc' by '~' to fix ordering of release(s) (candidates)
 * using the void release_replace_rc(char *ver) function above.
 */
static int openwrt_release_verrevcmp(const char *ver1, const char *ver2)
{
	char mver1[16], mver2[16];

	strncpy(mver1, ver1, sizeof(mver1) - 1);
	mver1[sizeof(mver1) - 1] = '\0';
	strncpy(mver2, ver2, sizeof(mver2) - 1);
	mver2[sizeof(mver2) - 1] = '\0';

	release_replace_rc(mver1);
	release_replace_rc(mver2);

	return verrevcmp(mver1, mver2);
}

/*
 * Select package_changes from branch to global list
 */
static void grab_changes(struct branch *br, unsigned int rev)
{
	struct package_changes *c, *n;

#ifdef AUC_DEBUG
	if (debug)
		fprintf(stderr, "grabbing changes for branch %s from revision %u\n", br->name, rev);
#endif

	list_for_each_entry(c, &br->package_changes, list) {
		if (c->revision == 0 || c->revision > rev) {
			n = malloc(sizeof(struct package_changes));
			memcpy(n, c, sizeof(struct package_changes));
			INIT_LIST_HEAD(&n->list);
			list_add_tail(&n->list, &selected_package_changes);
		}
	}
}

/**
 * UBUS response callbacks
 */
/*
 * rpc-sys packagelist
 * append array of package names to blobbuf given in req->priv
 */
#define ANSI_ESC "\x1b"
#define ANSI_COLOR_RESET ANSI_ESC "[0m"
#define ANSI_COLOR_RED ANSI_ESC "[1;31m"
#define ANSI_COLOR_GREEN ANSI_ESC "[1;32m"
#define ANSI_COLOR_BLUE ANSI_ESC "[1;34m"
#define ANSI_CURSOR_SAFE "[s"
#define ANSI_CURSOR_RESTORE "[u"
#define ANSI_ERASE_LINE "[K"

#define PKG_UPGRADE 0x1
#define PKG_DOWNGRADE 0x2
#define PKG_NOT_FOUND 0x4
#define PKG_ERROR 0x8

static bool ask_user(const char *message)
{
	char user_input;
	fflush(stdin);
	fprintf(stderr, "%s [N/y] ", message);
	user_input = getchar();
	fflush(stdin);
	if ((user_input == 'y') || (user_input == 'Y'))
		return true;

	return false;
}

static inline bool is_builtin_pkg(const char *pkgname)
{
	return !strcmp(pkgname, "libc") ||
		!strcmp(pkgname, "librt") ||
		!strcmp(pkgname, "libpthread") ||
		!strcmp(pkgname, "kernel");
}

static const char *apply_package_changes(const char *pkgname, bool interactive)
{
	struct package_changes *pkc;
	const char *mpkgname = pkgname;

	list_for_each_entry(pkc, &selected_package_changes, list) {
		/* package_change additions are dealt with later */
		if (!pkc->source)
			continue;

		if (strcmp(pkc->source, mpkgname))
			continue;

		if (!pkc->mandatory && interactive) {
			if (pkc->target)
				fprintf(stderr, "Package %s should be replaced by %s.\n", pkc->source, pkc->target);
			else
				fprintf(stderr, "Package %s should be removed.\n", pkc->source);

			if (dont_ask)
				pkc->mandatory = true;
			else
				pkc->mandatory = ask_user("Apply change");
		}

		if (!pkc->mandatory)
			continue;

		mpkgname = pkc->target;

		if (!mpkgname)
			break;
	}
	return mpkgname;
}

static void pkglist_check_cb(struct ubus_request *req, int type, struct blob_attr *msg)
{
	int *status = (int *)req->priv;
	struct blob_attr *tb[__PACKAGES_MAX], *cur;
	struct avl_pkg *pkg;
	int rem;
	int cmpres;
	const char *pkgname;
	struct package_changes *pkc;

	blobmsg_parse(packages_policy, __PACKAGES_MAX, tb, blobmsg_data(msg), blobmsg_len(msg));

	if (!tb[PACKAGES_PACKAGES])
		return;

	blobmsg_for_each_attr(cur, tb[PACKAGES_PACKAGES], rem) {
		pkgname = blobmsg_name(cur);
		if (is_builtin_pkg(pkgname))
			continue;

		pkgname = apply_package_changes(pkgname, true);
		if (!pkgname) {
			fprintf(stderr, " %s: %s%s -> (not installed)%s\n",
				blobmsg_name(cur), ANSI_COLOR_BLUE,
				blobmsg_get_string(cur), ANSI_COLOR_RESET);
			continue;
		}

		pkg = avl_find_element(&pkg_tree, pkgname, pkg, avl);
		if (!pkg) {
			fprintf(stderr, "installed package %s%s%s cannot be found in remote list!\n",
				ANSI_COLOR_RED, pkgname, ANSI_COLOR_RESET);
			*status |= PKG_NOT_FOUND;
			continue;
		}

		if (pkgname != blobmsg_name(cur)) {
			fprintf(stderr, " %s%s: %s -> %s: %s%s\n", ANSI_COLOR_BLUE,
				blobmsg_name(cur),
				blobmsg_get_string(cur), pkgname, pkg->version,
				ANSI_COLOR_RESET);
			*status |= PKG_UPGRADE;
			continue;
		}

		cmpres = verrevcmp(blobmsg_get_string(cur), pkg->version);
		if (cmpres < 0)
			*status |= PKG_UPGRADE;

		if (cmpres > 0)
			*status |= PKG_DOWNGRADE;

		if (cmpres
#ifdef AUC_DEBUG
		|| debug
#endif
			)
			fprintf(stderr, " %s: %s%s -> %s%s\n", blobmsg_name(cur),
				(!cmpres)?"":(cmpres > 0)?ANSI_COLOR_RED:ANSI_COLOR_GREEN,
				blobmsg_get_string(cur), pkg->version,
				(cmpres)?ANSI_COLOR_RESET:"");
	}

	list_for_each_entry(pkc, &selected_package_changes, list) {
		/* deal only with package_change additions now */
		if (pkc->source)
			continue;

		pkg = avl_find_element(&pkg_tree, pkc->target, pkg, avl);
		if (!pkg) {
			fprintf(stderr, "new package %s%s%s cannot be found in remote list!\n",
				ANSI_COLOR_RED, pkc->target, ANSI_COLOR_RESET);
			*status |= PKG_NOT_FOUND;
			continue;
		}
		fprintf(stderr, " %s: %s(not installed) -> %s%s\n", pkc->target, ANSI_COLOR_BLUE,
			pkg->version, ANSI_COLOR_RESET);
	}
}

/*
 * rpc-sys packagelist
 * append array of package names to blobbuf given in req->priv
 */
static void pkglist_req_cb(struct ubus_request *req, int type, struct blob_attr *msg) {
	struct blob_buf *buf = (struct blob_buf *)req->priv;
	struct blob_attr *tb[__PACKAGES_MAX];
	struct blob_attr *cur;
	int rem;
	struct avl_pkg *pkg;
	void *table;
	const char *pkgname;
	struct package_changes *pkc;

	blobmsg_parse(packages_policy, __PACKAGES_MAX, tb, blob_data(msg), blob_len(msg));

	if (!tb[PACKAGES_PACKAGES]) {
		fprintf(stderr, "No packagelist received\n");
		return;
	}

	table = blobmsg_open_table(buf, "packages_versions");

	blobmsg_for_each_attr(cur, tb[PACKAGES_PACKAGES], rem) {
		pkgname = blobmsg_name(cur);
		if (is_builtin_pkg(pkgname))
			continue;

		pkgname = apply_package_changes(pkgname, false);
		pkg = avl_find_element(&pkg_tree, pkgname, pkg, avl);
		if (!pkg)
			continue;

		blobmsg_add_string(buf, pkgname, pkg->version);
	}

	list_for_each_entry(pkc, &selected_package_changes, list) {
		/* add new packages to request */
		if (pkc->source)
			continue;

		pkg = avl_find_element(&pkg_tree, pkc->target, pkg, avl);
		if (!pkg)
			continue;

		blobmsg_add_string(buf, pkc->target, pkg->version);
	}
	blobmsg_close_table(buf, table);
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


	if (!tb[BOARD_RELEASE]) {
		fprintf(stderr, "No release received\n");
		rc=-ENODATA;
		return;
	}

	blobmsg_parse(release_policy, __RELEASE_MAX, rel,
			blobmsg_data(tb[BOARD_RELEASE]), blobmsg_data_len(tb[BOARD_RELEASE]));

	if (!rel[RELEASE_TARGET] ||
	    !rel[RELEASE_DISTRIBUTION] ||
	    !rel[RELEASE_VERSION] ||
	    !rel[RELEASE_REVISION]) {
		fprintf(stderr, "No release information received\n");
		rc=-ENODATA;
		return;
	}

	target = strdup(blobmsg_get_string(rel[RELEASE_TARGET]));
	distribution = strdup(blobmsg_get_string(rel[RELEASE_DISTRIBUTION]));
	version = strdup(blobmsg_get_string(rel[RELEASE_VERSION]));
	revision = strdup(blobmsg_get_string(rel[RELEASE_REVISION]));

	if (!strcmp(target, "x86/64") || !strcmp(target, "x86/generic")) {
		/*
		 * ugly work-around ahead:
		 * ignore board name on generic x86 targets, as image name is always 'generic'
		 */
		board_name = strdup("generic");
	} else {
		if (!tb[BOARD_BOARD_NAME]) {
			fprintf(stderr, "No board name received\n");
			rc=-ENODATA;
			return;
		}
		board_name = strdup(blobmsg_get_string(tb[BOARD_BOARD_NAME]));
	}

	if (tb[BOARD_ROOTFS_TYPE])
		rootfs_type = strdup(blobmsg_get_string(tb[BOARD_ROOTFS_TYPE]));

	blobmsg_add_string(buf, "target", target);
	blobmsg_add_string(buf, "version", version);
	blobmsg_add_string(buf, "revision", revision);
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

	if (tb[UPGTEST_STDERR])
		fprintf(stderr, "%s", blobmsg_get_string(tb[UPGTEST_STDERR]));
	else if (*valid == 0)
		fprintf(stderr, "image verification failed\n");
	else
		fprintf(stderr, "image verification succeeded\n");
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

struct jsonblobber {
	json_tokener *tok;
	struct blob_buf *outbuf;
};

static void request_done(struct uclient *cl)
{
	struct jsonblobber *jsb = (struct jsonblobber *)cl->priv;
	if (jsb) {
		json_tokener_free(jsb->tok);
		free(jsb);
	};

	uclient_disconnect(cl);
	uloop_end();
}

static void header_done_cb(struct uclient *cl)
{
	struct blob_attr *tb[__H_MAX];
	struct jsonblobber *jsb = (struct jsonblobber *)cl->priv;
	struct blob_buf *outbuf = NULL;

	if (jsb)
		outbuf = jsb->outbuf;

	uint64_t resume_offset = 0, resume_end, resume_size;

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

	DPRINTF("status code: %d\n", cl->status_code);
	DPRINTF("headers:\n%s\n", blobmsg_format_json_indent(cl->meta, true, 0));
	blobmsg_parse(header_policy, __H_MAX, tb, blob_data(cl->meta), blob_len(cl->meta));

	switch (cl->status_code) {
	case 400:
		request_done(cl);
		rc=-ESRCH;
		break;
	case 422:
		fprintf(stderr, "unknown package '%s' requested.\n",
			blobmsg_get_string(tb[H_UNKNOWN_PACKAGE]));
		rc=-ENOPKG;
		request_done(cl);
		break;
	case 201:
	case 202:
		retry = true;
		if (!outbuf)
			break;

		blobmsg_add_u32(outbuf, "status", cl->status_code);

		if (tb[H_QUEUE_POSITION])
			blobmsg_add_u32(outbuf, "queue_position", blobmsg_get_u32(tb[H_QUEUE_POSITION]));

		break;
	case 200:
		retry = false;
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
	case 500:
		/* server may reply JSON object */
		break;

	default:
		DPRINTF("HTTP error %d\n", cl->status_code);
		request_done(cl);
		break;
	}
}

static void read_data_cb(struct uclient *cl)
{
	char buf[256];
	int len;
	json_object *jsobj;
	struct blob_buf *outbuf = NULL;
	json_tokener *tok = NULL;
	struct jsonblobber *jsb = (struct jsonblobber *)cl->priv;

	if (!jsb) {
		while (1) {
			len = uclient_read(cl, buf, sizeof(buf));
			if (!len)
				return;

			out_bytes += len;
			write(output_fd, buf, len);
		}
		return;
	}

	outbuf = jsb->outbuf;
	tok = jsb->tok;

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
			blobmsg_add_json_element(outbuf, "reply", jsobj);

			json_object_put(jsobj);
			break;
		}
	}
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
	struct jsonblobber *jsb = NULL;
	int rc = -ENOENT;
	char *post_data;
	out_offset = 0;
	out_bytes = 0;
	out_len = 0;

#ifdef AUC_DEBUG
	if (debug)
		fprintf(stderr, "Requesting URL: %s\n", url);
#endif

	if (outbuf) {
		jsb = malloc(sizeof(struct jsonblobber));
		jsb->outbuf = outbuf;
		jsb->tok = json_tokener_new();
	};

	if (!ucl) {
		ucl = uclient_new(url, NULL, &check_cb);
		uclient_http_set_ssl_ctx(ucl, ssl_ops, ssl_ctx, 1);
		ucl->timeout_msecs = REQ_TIMEOUT * 1000;
	} else {
		uclient_set_url(ucl, url, NULL);
	}

	ucl->priv = jsb;

	rc = uclient_connect(ucl);
	if (rc)
		return rc;

	rc = uclient_http_set_request_type(ucl, inbuf?"POST":"GET");
	if (rc)
		return rc;

	uclient_http_reset_headers(ucl);
	uclient_http_set_header(ucl, "User-Agent", user_agent);
	if (inbuf) {
		uclient_http_set_header(ucl, "Content-Type", "application/json");
		post_data = blobmsg_format_json(inbuf->head, true);
		uclient_write(ucl, post_data, strlen(post_data));
	}
	rc = uclient_request(ucl);
	if (rc)
		return rc;

	uloop_run();

	return 0;
}

/**
 * ustream-ssl
 */
static int init_ustream_ssl(void) {
	glob_t gl;
	int i;

	dlh = dlopen("libustream-ssl.so", RTLD_LAZY | RTLD_LOCAL);
	if (!dlh)
		return -ENOENT;

	ssl_ops = dlsym(dlh, "ustream_ssl_ops");
	if (!ssl_ops)
		return -ENOENT;

	ssl_ctx = ssl_ops->context_new(false);

	glob("/etc/ssl/certs/*.crt", 0, NULL, &gl);
	if (!gl.gl_pathc)
		return -ENOKEY;

	for (i = 0; i < gl.gl_pathc; i++)
		ssl_ops->context_add_ca_crt_file(ssl_ctx, gl.gl_pathv[i]);

	return 0;
}

static char* alloc_replace_var(char *in, const char *var, const char *replace)
{
	char *tmp = in;
	char *res = NULL;
	char *eptr;

	while ((tmp = strchr(tmp, '{'))) {
		++tmp;
		eptr = strchr(tmp, '}');
		if (!eptr)
			return NULL;

		if (!strncmp(tmp, var, (unsigned int)(eptr - tmp))) {
			asprintf(&res, "%.*s%s%s",
				(unsigned int)(tmp - in) - 1, in, replace, eptr + 1);
			break;
		}
	}

	if (!res)
		res = strdup(in);

	return res;
}

static int request_target(struct branch_version *bver, char *url)
{
	static struct blob_buf boardbuf;
	struct blob_attr *tbr[__REPLY_MAX], *tb[__TARGET_MAX];

	blobmsg_buf_init(&boardbuf);

	if ((rc = server_request(url, NULL, &boardbuf))) {
		blob_buf_free(&boardbuf);
		return rc;
	}

	blobmsg_parse(reply_policy, __REPLY_MAX, tbr, blob_data(boardbuf.head), blob_len(boardbuf.head));

	if (!tbr[REPLY_OBJECT])
		return -ENODATA;

	blobmsg_parse(target_policy, __TARGET_MAX, tb, blobmsg_data(tbr[REPLY_OBJECT]), blobmsg_len(tbr[REPLY_OBJECT]));

	if (!tb[TARGET_METADATA_VERSION] ||
	    !tb[TARGET_ARCH_PACKAGES] ||
	    !tb[TARGET_IMAGES] ||
	    !tb[TARGET_TARGET]) {
		blob_buf_free(&boardbuf);
		return -ENODATA;
	}

	if (blobmsg_get_u32(tb[TARGET_METADATA_VERSION]) != 1) {
		blob_buf_free(&boardbuf);
		return -EPFNOSUPPORT;
	}

	if (strcmp(blobmsg_get_string(tb[TARGET_TARGET]), target))
		return -EINVAL;

	if (strcmp(blobmsg_get_string(tb[TARGET_ARCH_PACKAGES]), bver->branch->arch_packages))
		return -EINVAL;

	if (tb[TARGET_VERSION_CODE])
		bver->version_code = strdup(blobmsg_get_string(tb[TARGET_VERSION_CODE]));

	if (tb[TARGET_VERSION_NUMBER])
		bver->version_number = strdup(blobmsg_get_string(tb[TARGET_VERSION_NUMBER]));

	blob_buf_free(&boardbuf);
	return 0;
};

static char* validate_target(struct blob_attr *branch)
{
	struct blob_attr *cur;
	int rem;

	blobmsg_for_each_attr(cur, branch, rem)
		if (!strcmp(blobmsg_name(cur), target))
			return strdup(blobmsg_get_string(cur));

	return NULL;
}

static void process_branch(struct blob_attr *branch, bool only_active)
{
	struct blob_attr *tb[__BRANCH_MAX], *pkc[__PACKAGE_CHANGES_MAX];
	struct blob_attr *curver, *curpkc;
	int remver, rempkc;
	struct branch *br;
	struct package_changes *pkce;
	char *tmp, *board_json_file;
	const char *brname;

	blobmsg_parse(branches_policy, __BRANCH_MAX, tb, blobmsg_data(branch), blobmsg_len(branch));

	/* mandatory fields */
	if (!(tb[BRANCH_ENABLED] && blobmsg_get_bool(tb[BRANCH_ENABLED]) &&
		tb[BRANCH_NAME] && tb[BRANCH_PATH] && tb[BRANCH_PATH_PACKAGES] &&
		tb[BRANCH_VERSIONS] && tb[BRANCH_TARGETS]))
		return;

	brname = blobmsg_get_string(tb[BRANCH_NAME]);
	if (only_active && strncmp(brname, version, strlen(brname)))
		return;

	br = calloc(1, sizeof(struct branch));
	avl_init(&br->versions, avl_verrevcmp, false, NULL);
	INIT_LIST_HEAD(&br->package_changes);

	/* check if target is offered in branch and get arch_packages */
	br->arch_packages = validate_target(tb[BRANCH_TARGETS]);
	if (!br->arch_packages) {
		free(br);
		return;
	}

	if (tb[BRANCH_GIT_BRANCH])
		br->git_branch = strdup(blobmsg_get_string(tb[BRANCH_GIT_BRANCH]));

	if (tb[BRANCH_BRANCH_OFF_REV])
		br->branch_off_rev = blobmsg_get_u32(tb[BRANCH_BRANCH_OFF_REV]);
	else
		br->branch_off_rev = 0;

	if (tb[BRANCH_SNAPSHOT])
		br->snapshot = blobmsg_get_bool(tb[BRANCH_SNAPSHOT]);
	else
		br->snapshot = false;

	br->name = strdup(blobmsg_get_string(tb[BRANCH_NAME]));
	br->path_packages = alloc_replace_var(blobmsg_get_string(tb[BRANCH_PATH_PACKAGES]), "branch", br->name);
	if (!br->path_packages) {
		free(br->name);
		free(br->arch_packages);
		free(br);
		return;
	}

	/* parse package changes */
	blobmsg_for_each_attr(curpkc, tb[BRANCH_PACKAGE_CHANGES], rempkc) {
		if (blobmsg_type(curpkc) != BLOBMSG_TYPE_TABLE)
			continue;

		blobmsg_parse(package_changes_policy, __PACKAGE_CHANGES_MAX, pkc, blobmsg_data(curpkc), blobmsg_len(curpkc));
		if (!pkc[PACKAGE_CHANGES_REVISION] || (!pkc[PACKAGE_CHANGES_SOURCE] && !pkc[PACKAGE_CHANGES_TARGET]))
			continue;

		pkce = calloc(1, sizeof(struct package_changes));
		if (!pkce)
			break;

		if (pkc[PACKAGE_CHANGES_SOURCE])
			pkce->source = strdup(blobmsg_get_string(pkc[PACKAGE_CHANGES_SOURCE]));

		if (pkc[PACKAGE_CHANGES_TARGET])
			pkce->target = strdup(blobmsg_get_string(pkc[PACKAGE_CHANGES_TARGET]));

		pkce->revision = blobmsg_get_u32(pkc[PACKAGE_CHANGES_REVISION]);

		if (pkc[PACKAGE_CHANGES_MANDATORY])
			pkce->mandatory = blobmsg_get_bool(pkc[PACKAGE_CHANGES_MANDATORY]);

		list_add_tail(&pkce->list, &br->package_changes);
	}

	/* add each version of the branch */
	blobmsg_for_each_attr(curver, tb[BRANCH_VERSIONS], remver) {
		if (blobmsg_type(curver) != BLOBMSG_TYPE_STRING)
			continue;

		struct branch_version *bver = calloc(1, sizeof(struct branch_version));
		bver->snapshot = !!strcasestr(blobmsg_get_string(curver), "snapshot");
		bver->path = alloc_replace_var(blobmsg_get_string(tb[BRANCH_PATH]), "version", blobmsg_get_string(curver));
		if (!bver->path) {
			free(bver);
			continue;
		}
		bver->version = strdup(blobmsg_get_string(curver));
		if (!bver->version) {
			free(bver->path);
			free(bver);
			continue;
		}
		bver->branch = br;
		if (asprintf(&board_json_file, "%s/%s/%s/%s/%s/%s/%s%s", serverurl, API_JSON,
			     API_JSON_VERSION, bver->path, API_TARGETS, target, board_name,
			     API_JSON_EXT) < 0) {
			free(bver->version);
			free(bver->path);
			free(bver);
			continue;
		}
		tmp = board_json_file;
		while ((tmp = strchr(tmp, ',')))
			*tmp = '_';

		if (request_target(bver, board_json_file)) {
			free(board_json_file);
			free(bver->version);
			free(bver->path);
			free(bver);
			continue;
		}
		free(board_json_file);
		bver->avl.key = bver->version;
		avl_insert(&br->versions, &bver->avl);
	}

	br->avl.key = br->name;
	avl_insert(&branches, &br->avl);
}

static int request_branches(bool only_active)
{
	static struct blob_buf brbuf;
	struct blob_attr *cur;
	struct blob_attr *tb[__REPLY_MAX];
	int rem;
	char url[256];
	struct blob_attr *data;

	blobmsg_buf_init(&brbuf);
	snprintf(url, sizeof(url), "%s/%s/%s/%s%s", serverurl, API_JSON,
		API_JSON_VERSION, API_BRANCHES, API_JSON_EXT);

	if ((rc = server_request(url, NULL, &brbuf))) {
		blob_buf_free(&brbuf);
		return rc;
	};

	blobmsg_parse(reply_policy, __REPLY_MAX, tb, blob_data(brbuf.head), blob_len(brbuf.head));

	/* newer server API replies OBJECT, older API replies ARRAY... */
	if ((!tb[REPLY_ARRAY] && !tb[REPLY_OBJECT]))
		return -ENODATA;

	if (tb[REPLY_OBJECT])
		data = tb[REPLY_OBJECT];
	else
		data = tb[REPLY_ARRAY];

	blobmsg_for_each_attr(cur, data, rem)
		process_branch(cur, only_active);

	blob_buf_free(&brbuf);

	return 0;
}

static void free_branches()
{
	struct branch *br, *tmp;
	struct branch_version *bver, *tmp2;
	struct package_changes *pkce, *tmp3;

	avl_for_each_element_safe(&branches, br, avl, tmp) {
		free(br->name);
		free(br->path_packages);
		free(br->arch_packages);

		avl_for_each_element_safe(&br->versions, bver, avl, tmp2) {
			avl_delete(&br->versions, &bver->avl);
			free(bver->version);
			free(bver->version_code);
			free(bver->version_number);
			free(bver->path);
			free(bver);
		}

		list_for_each_entry_safe(pkce, tmp3, &br->package_changes, list) {
			list_del(&pkce->list);
			free(pkce->source);
			free(pkce->target);
			free(pkce);
		}

		avl_delete(&branches, &br->avl);
	}
}

static struct branch *get_current_branch()
{
	struct branch *br, *abr = NULL;

	avl_for_each_element(&branches, br, avl) {
		/* if branch name doesn't match version *prefix*, skip */
		if (!strncasecmp(br->name, version, strlen(br->name))) {
			abr = br;
			break;
		}
	}

	return abr;
}

static int revision_from_version_code(const char *version_code)
{
	int res;

	if (sscanf(version_code, "r%d-", &res) == 1)
		return res;

	return -1;
}

static struct branch_version *select_branch(char *name, char *select_version)
{
	struct branch *br;
	struct branch_version *bver, *abver = NULL;

	if (!name)
		name = version;

	avl_for_each_element(&branches, br, avl) {
		/* if branch name doesn't match version *prefix*, skip */
		if (strncasecmp(br->name, name, strlen(br->name)))
			continue;

		avl_for_each_element(&br->versions, bver, avl) {
			if (select_version) {
				if (!strcasecmp(bver->version, select_version)) {
					abver = bver;
					break;
				}
			} else {
				if (!strcasecmp(name, "snapshot")) {
					/* we are on the main snapshot branch */
					if (br->snapshot && bver->snapshot) {
						abver = bver;
						break;
					}
				} else {
					/* skip main snapshot branch */
					if (br->snapshot)
						continue;

					if (strcasestr(version, "snapshot")) {
						/* we are on a stable snapshot branch or coming from main snapshot branch */
						if (bver->snapshot) {
							abver = bver;
							break;
						}
					} else {
						if (bver->snapshot)
							continue;

						if (!abver || (openwrt_release_verrevcmp(abver->version, bver->version) < 0))
							abver = bver;
					}
				}
			}
		}
		if (abver)
			break;
	}

	return abver;
}

static int add_upg_packages(struct blob_attr *reply, char *arch)
{
	struct blob_attr *tbr[__REPLY_MAX];
	struct blob_attr *tba[__PACKAGES_MAX];
	struct blob_attr *packages;
	struct blob_attr *cur;
	int rem;
	struct avl_pkg *avpk;

	blobmsg_parse(reply_policy, __REPLY_MAX, tbr, blob_data(reply), blob_len(reply));

	if (!tbr[REPLY_OBJECT])
			return -ENODATA;

	if (arch) {
		blobmsg_parse(packages_policy, __PACKAGES_MAX, tba, blobmsg_data(tbr[REPLY_OBJECT]), blobmsg_len(tbr[REPLY_OBJECT]));
		if (!tba[PACKAGES_ARCHITECTURE] ||
		    !tba[PACKAGES_PACKAGES])
			return -ENODATA;

		if (strcmp(blobmsg_get_string(tba[PACKAGES_ARCHITECTURE]), arch))
			return -EBADMSG;

		packages = tba[PACKAGES_PACKAGES];
	} else {
		packages = tbr[REPLY_OBJECT];
	}

	blobmsg_for_each_attr(cur, packages, rem) {
		avpk = calloc(1, sizeof(struct avl_pkg));
		if (!avpk)
			return -ENOMEM;

		avpk->name = strdup(blobmsg_name(cur));
		if (!avpk->name) {
			free(avpk);
			return -ENOMEM;
		}

		avpk->version = strdup(blobmsg_get_string(cur));
		if (!avpk->version) {
			free(avpk->name);
			free(avpk);
			return -ENOMEM;
		}

		avpk->avl.key = avpk->name;
		if (avl_insert(&pkg_tree, &avpk->avl)) {

#ifdef AUC_DEBUG
			if (debug)
				fprintf(stderr, "failed to insert package %s (%s)!\n", blobmsg_name(cur), blobmsg_get_string(cur));
#endif

			if (avpk->name)
				free(avpk->name);

			if (avpk->version)
				free(avpk->version);

			free(avpk);
		}
	}

	return 0;
}

static int request_packages(struct branch_version *bver)
{
	static struct blob_buf pkgbuf, archpkgbuf;
	char url[256];
	int ret;

	fprintf(stderr, "Requesting package lists...\n");

	blobmsg_buf_init(&archpkgbuf);
	snprintf(url, sizeof(url), "%s/%s/%s/%s/%s/%s/%s%s", serverurl, API_JSON,
		API_JSON_VERSION, bver->path, API_TARGETS, target, API_INDEX, API_JSON_EXT);
	if ((rc = server_request(url, NULL, &archpkgbuf))) {
		blob_buf_free(&archpkgbuf);
		return rc;
	};

	ret = add_upg_packages(archpkgbuf.head, bver->branch->arch_packages);
	blob_buf_free(&archpkgbuf);

	if (ret)
		return ret;

	blobmsg_buf_init(&pkgbuf);
	snprintf(url, sizeof(url), "%s/%s/%s/%s/%s/%s-%s%s", serverurl, API_JSON,
		API_JSON_VERSION, bver->path, API_PACKAGES, bver->branch->arch_packages,
		API_INDEX, API_JSON_EXT);
	if ((rc = server_request(url, NULL, &pkgbuf))) {
		blob_buf_free(&archpkgbuf);
		blob_buf_free(&pkgbuf);
		return rc;
	};

	ret = add_upg_packages(pkgbuf.head, NULL);
	blob_buf_free(&pkgbuf);

	return ret;
}


static int check_installed_packages(void)
{
	static struct blob_buf allpkg;
	uint32_t id;
	int status = 0;

	blob_buf_init(&allpkg, 0);
	blobmsg_add_u8(&allpkg, "all", 1);
	blobmsg_add_string(&allpkg, "dummy", "foo");
	if (ubus_lookup_id(ctx, "rpc-sys", &id) ||
	    ubus_invoke(ctx, id, "packagelist", allpkg.head, pkglist_check_cb, &status, 3000)) {
		fprintf(stderr, "cannot request packagelist from rpcd\n");
		status |= PKG_ERROR;
	}

	return status;
}

static int req_add_selected_packages(struct blob_buf *req)
{
	static struct blob_buf allpkg;
	uint32_t id;

	blob_buf_init(&allpkg, 0);
	blobmsg_add_u8(&allpkg, "all", 0);
	blobmsg_add_string(&allpkg, "dummy", "foo");
	if (ubus_lookup_id(ctx, "rpc-sys", &id) ||
	    ubus_invoke(ctx, id, "packagelist", allpkg.head, pkglist_req_cb, req, 3000)) {
		fprintf(stderr, "cannot request packagelist from rpcd\n");
		return -EFAULT;
	}

	return 0;
}

#if defined(__amd64__) || defined(__i386__)
static int system_is_efi(void)
{
	const char efidname[] = "/sys/firmware/efi/efivars";
	int fd = open(efidname, O_DIRECTORY | O_PATH);

	if (fd != -1) {
		close(fd);
		return 1;
	} else {
		return 0;
	}
}
#else
static inline int system_is_efi(void) { return 0; }
#endif

static int get_image_by_type(struct blob_attr *images, const char *typestr, const char *fstype, char **image_name, char **image_sha256)
{
	struct blob_attr *tb[__IMAGES_MAX];
	struct blob_attr *cur;
	int rem, ret = -ENOENT;

	blobmsg_for_each_attr(cur, images, rem) {
		blobmsg_parse(images_policy, __IMAGES_MAX, tb, blobmsg_data(cur), blobmsg_len(cur));
		if (!tb[IMAGES_FILESYSTEM] ||
		    !tb[IMAGES_NAME] ||
		    !tb[IMAGES_TYPE] ||
		    !tb[IMAGES_SHA256])
			continue;

		if (fstype && strcmp(blobmsg_get_string(tb[IMAGES_FILESYSTEM]), fstype))
			continue;

		if (!strcmp(blobmsg_get_string(tb[IMAGES_TYPE]), typestr)) {
			*image_name = strdup(blobmsg_get_string(tb[IMAGES_NAME]));
			*image_sha256 = strdup(blobmsg_get_string(tb[IMAGES_SHA256]));
			ret = 0;
			break;
		}
	}

	return ret;
}

static int select_image(struct blob_attr *images, const char *target_fstype, char **image_name, char **image_sha256)
{
	const char *combined_type;
	const char *fstype = rootfs_type;
	int ret = -ENOENT;

	if (target_fstype)
		fstype = target_fstype;

	if (system_is_efi())
		combined_type = "combined-efi";
	else
		combined_type = "combined";

	DPRINTF("images: %s\n", blobmsg_format_json_indent(images, true, 0));

	if (fstype) {
		ret = get_image_by_type(images, "sysupgrade", fstype, image_name, image_sha256);
		if (!ret)
			return 0;

		ret = get_image_by_type(images, combined_type, fstype, image_name, image_sha256);
		if (!ret)
			return 0;

		ret = get_image_by_type(images, "sdcard", fstype, image_name, image_sha256);
		if (!ret)
			return 0;
	}

	/* fallback to squashfs unless fstype requested explicitly */
	if (!target_fstype) {
		ret = get_image_by_type(images, "sysupgrade", "squashfs", image_name, image_sha256);
		if (!ret)
			return 0;

		ret = get_image_by_type(images, combined_type, "squashfs", image_name, image_sha256);
		if (!ret)
			return 0;

		ret = get_image_by_type(images, "sdcard", fstype, image_name, image_sha256);
	}

	return ret;
}

static bool validate_sha256(char *filename, char *sha256str)
{
	char *cmd = calloc(strlen(SHA256SUM) + 1 + strlen(filename) + 1, sizeof(char));
	size_t reslen = (64 + 2 + strlen(filename) + 1) * sizeof(char);
	char *resstr = malloc(reslen);
	FILE *f;
	bool ret = false;

	strcpy(cmd, SHA256SUM);
	strcat(cmd, " ");
	strcat(cmd, filename);

	f = popen(cmd, "r");
	if (!f)
		goto sha256free;

	if (fread(resstr, reslen, 1, f) < 1)
		goto sha256close;

	if (!strncmp(sha256str, resstr, 64))
		ret = true;

sha256close:
	fflush(f);
	pclose(f);
sha256free:
	free(cmd);
	free(resstr);

	return ret;
}

static inline bool status_delay(const char *status)
{
	return !strcmp(API_STATUS_QUEUED, status) ||
	       !strcmp(API_STATUS_STARTED, status);
}

static void usage(const char *arg0)
{
	fprintf(stdout, "%s: Attended sysUpgrade CLI client\n", arg0);
	fprintf(stdout, "Usage: auc [-b <branch>] [-B <ver>] [-c] %s[-f] [-h] [-r] [-y]\n",
#ifdef AUC_DEBUG
"[-d] "
#else
""
#endif
		);
	fprintf(stdout, " -b <branch>\tuse specific release branch\n");
	fprintf(stdout, " -B <ver>\tuse specific release version\n");
	fprintf(stdout, " -c\t\tonly check if system is up-to-date\n");
#ifdef AUC_DEBUG
	fprintf(stdout, " -d\t\tenable debugging output\n");
#endif
	fprintf(stdout, " -f\t\tuse force\n");
	fprintf(stdout, " -h\t\toutput help\n");
	fprintf(stdout, " -n\t\tdry-run (don't download or upgrade)\n");
	fprintf(stdout, " -r\t\tcheck only for release upgrades\n");
	fprintf(stdout, " -F <fstype>\toverride filesystem type\n");
	fprintf(stdout, " -y\t\tdon't wait for user confirmation\n");
	fprintf(stdout, "\n");
	fprintf(stdout, "Please report issues to improve the server:\n");
	fprintf(stdout, "%s\n", server_issues);
}


/* this main function is too big... todo: split */
int main(int args, char *argv[]) {
	static struct blob_buf checkbuf, infobuf, reqbuf, imgbuf, upgbuf;
	struct branch *current_branch, *running_branch;
	struct branch_version *target_version;
	int running_revision, covered_revision = 0;
	uint32_t id;
	int valid;
	char url[256];
	char *sanetized_board_name, *image_name, *image_sha256, *tmp;
	char *cmd_target_branch = NULL, *cmd_target_version = NULL, *cmd_target_fstype = NULL;
	struct blob_attr *tbr[__REPLY_MAX];
	struct blob_attr *tb[__TARGET_MAX] = {}; /* make sure tb is NULL initialized even if blobmsg_parse isn't called */
	struct stat imgstat;
	bool check_only = false;
	bool retry_delay = false;
	bool upg_check = false;
	bool dry_run = false;
	int revcmp = 0;
	int addargs;
	unsigned char argc = 1;
	bool force = false, use_get = false, in_queue = false, release_only = false;

	snprintf(user_agent, sizeof(user_agent), "%s/%s", argv[0], AUC_VERSION);
	fprintf(stdout, "%s\n", user_agent);

	while (argc<args) {
		if (!strncmp(argv[argc], "-h", 3) ||
		    !strncmp(argv[argc], "--help", 7)) {
			usage(argv[0]);
			return 0;
		}

		addargs = 0;
#ifdef AUC_DEBUG
		if (!strncmp(argv[argc], "-d", 3))
			debug = 1;
#endif
		if (!strncmp(argv[argc], "-b", 3)) {
			cmd_target_branch = argv[argc + 1];
			addargs = 1;
		}

		if (!strncmp(argv[argc], "-B", 3)) {
			cmd_target_version = argv[argc + 1];
			addargs = 1;
		}

		if (!strncmp(argv[argc], "-c", 3))
			check_only = true;

		if (!strncmp(argv[argc], "-f", 3))
			force = true;

		if (!strncmp(argv[argc], "-F", 3)) {
			cmd_target_fstype = argv[argc + 1];
			addargs = 1;
		}

		if (!strncmp(argv[argc], "-n", 3))
			dry_run = true;

		if (!strncmp(argv[argc], "-r", 3))
			release_only = true;

		if (!strncmp(argv[argc], "-y", 3))
			dont_ask = true;

		argc += 1 + addargs;
	};

	if (load_config()) {
		rc=-EFAULT;
		goto freeubus;
	}

	if (chdir("/tmp")) {
		rc=-EFAULT;
		goto freeconfig;
	}

	if (!strncmp(serverurl, "https", 5)) {
		rc = init_ustream_ssl();
		if (rc == -2) {
			fprintf(stderr, "No CA certificates loaded, please install ca-certificates\n");
			rc=-1;
			goto freessl;
		}

		if (rc || !ssl_ctx) {
			fprintf(stderr, "SSL support not available, please install ustream-ssl\n");
			rc=-EPROTONOSUPPORT;
			goto freessl;
		}
	}

	uloop_init();
	ctx = ubus_connect(NULL);
	if (!ctx) {
		fprintf(stderr, "failed to connect to ubus.\n");
		return -1;
	}

	blobmsg_buf_init(&checkbuf);
	blobmsg_buf_init(&infobuf);
	blobmsg_buf_init(&reqbuf);
	blobmsg_buf_init(&imgbuf);
	/* ubus requires BLOBMSG_TYPE_UNSPEC */
	blob_buf_init(&upgbuf, 0);

	if (ubus_lookup_id(ctx, "system", &id) ||
	    ubus_invoke(ctx, id, "board", NULL, board_cb, &checkbuf, 3000)) {
		fprintf(stderr, "cannot request board info from procd\n");
		rc=-EFAULT;
		goto freebufs;
	}

	fprintf(stdout, "Server:    %s\n", serverurl);
	fprintf(stdout, "Running:   %s %s on %s (%s)\n", version, revision, target, board_name);
	if (cmd_target_fstype && rootfs_type && strcmp(rootfs_type, cmd_target_fstype))
		fprintf(stderr, "WARNING: will change rootfs type from '%s' to '%s'\n",
			rootfs_type, cmd_target_fstype);

	if (request_branches(!(cmd_target_branch || cmd_target_version))) {
		rc=-ENODATA;
		goto freeboard;
	}

	running_branch = get_current_branch();
	running_revision = revision_from_version_code(revision);
	if (!running_branch)
		fprintf(stderr, "WARNING: cannot determine currently running branch.\n");

	target_version = select_branch(cmd_target_branch, cmd_target_version);
	if (!target_version) {
		rc=-EINVAL;
		goto freebranches;
	}

	fprintf(stdout, "Available: %s %s\n", target_version->version_number, target_version->version_code);

	if (running_branch->snapshot && !target_version->branch->snapshot)
		revcmp = (running_revision < target_version->branch->branch_off_rev)?-1:1;
	else if (!running_branch->snapshot && target_version->branch->snapshot)
		revcmp = -1;
	else
		revcmp = verrevcmp(version, target_version->version_number);

	if (revcmp < 0)
			upg_check |= PKG_UPGRADE;
	else if (revcmp > 0)
			upg_check |= PKG_DOWNGRADE;

	if (release_only && !(upg_check & PKG_UPGRADE)) {
		fprintf(stderr, "Nothing to be updated. Use '-f' to force.\n");
		rc = 0;
		goto freebranches;
	}

	if (target_version->branch == running_branch)
		grab_changes(running_branch, running_revision);
	else if (revcmp > 0)
		fprintf(stderr, "WARNING: Downgrade to older branch may not work as expected!\n");
	else avl_for_element_range(running_branch, target_version->branch, current_branch, avl) {
		if (current_branch == running_branch)
			grab_changes(running_branch, running_revision);
		else
			grab_changes(current_branch, covered_revision);

		if (current_branch->branch_off_rev > 0)
			covered_revision = current_branch->branch_off_rev;
	}

	if ((rc = request_packages(target_version)))
		goto freebranches;

	upg_check |= check_installed_packages();
	if (upg_check & PKG_ERROR) {
		rc = -ENOPKG;
		goto freebranches;
	}

	if (!upg_check && !force) {
		fprintf(stderr, "Nothing to be updated. Use '-f' to force.\n");
		rc=0;
		goto freebranches;
	};

	if (!force && (upg_check & PKG_DOWNGRADE)) {
		fprintf(stderr, "Refusing to downgrade. Use '-f' to force.\n");
		rc = -ENOTRECOVERABLE;
		goto freebranches;
	};

	if (!force && (upg_check & PKG_NOT_FOUND)) {
		fprintf(stderr, "Not all installed packages found in remote lists. Use '-f' to force.\n");
		rc = -ENOTRECOVERABLE;
		goto freebranches;
	};

	if (check_only)
		goto freebranches;

	if (!dont_ask) {
		if (!ask_user("Are you sure you want to continue the upgrade process?")) {
			rc = 0;
			goto freebranches;
		}
	}

	blobmsg_add_string(&reqbuf, "version", target_version->version);
	blobmsg_add_string(&reqbuf, "version_code", target_version->version_code);
	blobmsg_add_string(&reqbuf, "target", target);

	if (cmd_target_fstype || rootfs_type)
		blobmsg_add_string(&reqbuf, "filesystem", cmd_target_fstype?cmd_target_fstype:rootfs_type);

	sanetized_board_name = strdup(board_name);
	tmp = sanetized_board_name;
	while ((tmp = strchr(tmp, ',')))
		*tmp = '_';

	blobmsg_add_string(&reqbuf, "profile", sanetized_board_name);
	blobmsg_add_u8(&reqbuf, "diff_packages", 1);

	req_add_selected_packages(&reqbuf);

	snprintf(url, sizeof(url), "%s/%s", serverurl, API_REQUEST);

	use_get = false;
	do {
		retry = false;

		DPRINTF("requesting from %s\n%s%s", url, use_get?"":blobmsg_format_json_indent(reqbuf.head, true, 0), use_get?"":"\n");

		rc = server_request(url, use_get?NULL:&reqbuf, &imgbuf);
		if (rc)
			break;

		blobmsg_parse(reply_policy, __REPLY_MAX, tbr, blob_data(imgbuf.head), blob_len(imgbuf.head));
		if (!tbr[REPLY_OBJECT])
			break;

		blobmsg_parse(target_policy, __TARGET_MAX, tb, blobmsg_data(tbr[REPLY_OBJECT]), blobmsg_len(tbr[REPLY_OBJECT]));

		/* for compatibility with old server version, also support status in 200 reply */
		if (tb[TARGET_STATUS]) {
			tmp = blobmsg_get_string(tb[TARGET_STATUS]);
			if (status_delay(tmp))
				retry = 1;
		}

		if (tb[TARGET_REQUEST_HASH]) {
			if (retry) {
				if (!retry_delay)
					fputs("Requesting build", stderr);

				retry_delay = 2;
				if (tb[TARGET_QUEUE_POSITION]) {
					fprintf(stderr, "%s%s (position in queue: %d)",
						ANSI_ESC, in_queue?ANSI_CURSOR_RESTORE:ANSI_CURSOR_SAFE,
						blobmsg_get_u32(tb[TARGET_QUEUE_POSITION]));
					in_queue = true;
				} else {
					if (in_queue)
						fprintf(stderr, "%s%s%s%s",
							ANSI_ESC, ANSI_CURSOR_RESTORE,
							ANSI_ESC, ANSI_ERASE_LINE);
					fputc('.', stderr);
					in_queue = false;
				}
			} else {
				retry_delay = 0;
			}
			if (!use_get) {
				snprintf(url, sizeof(url), "%s/%s/%s", serverurl,
					 API_REQUEST,
					 blobmsg_get_string(tb[TARGET_REQUEST_HASH]));
				DPRINTF("polling via GET %s\n", url);
			}
			use_get = true;
		} else if (retry_delay) {
			retry_delay = 0;
		}

#ifdef AUC_DEBUG
		if (debug && tb[TARGET_STDOUT])
			fputs(blobmsg_get_string(tb[TARGET_STDOUT]), stdout);

		if (debug && tb[TARGET_STDERR])
			fputs(blobmsg_get_string(tb[TARGET_STDERR]), stderr);
#endif

		if (retry) {
			blob_buf_free(&imgbuf);
			blobmsg_buf_init(&imgbuf);
			sleep(retry_delay);
		}
	} while(retry);

	free(sanetized_board_name);

	if (!tb[TARGET_IMAGES] || !tb[TARGET_BINDIR]) {
		if (!rc)
			rc=-EBADMSG;
		goto freebranches;
	}

	if ((rc = select_image(tb[TARGET_IMAGES], cmd_target_fstype, &image_name, &image_sha256)))
		goto freebranches;

	snprintf(url, sizeof(url), "%s/%s/%s/%s", serverurl, API_STORE,
	         blobmsg_get_string(tb[TARGET_BINDIR]),
	         image_name);

	if (dry_run) {
		fprintf(stderr, "\nImage available at %s\n", url);
		rc = 0;
		goto freebranches;
	}

	fprintf(stderr, "\nDownloading image from %s\n", url);
	rc = server_request(url, NULL, NULL);
	if (rc)
		goto freebranches;

	filename = uclient_get_url_filename(url, "firmware.bin");

	if (stat(filename, &imgstat)) {
		fprintf(stderr, "image download failed\n");
		rc=-EPIPE;
		goto freebranches;
	}

	if ((intmax_t)imgstat.st_size != out_len) {
		fprintf(stderr, "file size mismatch\n");
		unlink(filename);
		rc=-EMSGSIZE;
		goto freebranches;
	}

	if (!validate_sha256(filename, image_sha256)) {
		fprintf(stderr, "sha256 mismatch\n");
		unlink(filename);
		rc=-EBADMSG;
		goto freebranches;
	}

	if (strcmp(filename, "firmware.bin")) {
		if (rename(filename, "firmware.bin")) {
			fprintf(stderr, "can't rename to firmware.bin\n");
			unlink(filename);
			rc=-errno;
			goto freebranches;
		}
	}

	valid = 0;
	if (ubus_lookup_id(ctx, "rpc-sys", &id) ||
	    ubus_invoke(ctx, id, "upgrade_test", NULL, upgtest_cb, &valid, 15000)) {
		rc=-EFAULT;
		goto freebranches;
	}

	if (!valid) {
		rc=-EINVAL;
		goto freebranches;
	}

	fprintf(stdout, "invoking sysupgrade\n");
	blobmsg_add_u8(&upgbuf, "keep", 1);
	ubus_invoke(ctx, id, "upgrade_start", upgbuf.head, NULL, NULL, 120000);
	sleep(10);

freebranches:
	free_branches();
	if (rc && tb[TARGET_STDOUT]
#ifdef AUC_DEBUG
	    && !debug
#endif
	    )
		fputs(blobmsg_get_string(tb[TARGET_STDOUT]), stdout);
	if (rc && tb[TARGET_STDERR]
#ifdef AUC_DEBUG
	    && !debug
#endif
	    )
		fputs(blobmsg_get_string(tb[TARGET_STDERR]), stderr);

	if (tb[TARGET_DETAIL]) {
		fputs(blobmsg_get_string(tb[TARGET_DETAIL]), stderr);
		fputc('\n', stderr);
	}

freeboard:
	if (rootfs_type)
		free(rootfs_type);

	free(board_name);
	free(target);
	free(distribution);
	free(version);

freebufs:
	blob_buf_free(&checkbuf);
	blob_buf_free(&infobuf);
	blob_buf_free(&reqbuf);
	blob_buf_free(&imgbuf);
	blob_buf_free(&upgbuf);

freessl:
	if (ssl_ctx)
		ssl_ops->context_free(ssl_ctx);

freeconfig:
	free(serverurl);

freeubus:
	uloop_done();
	ubus_free(ctx);

	if (ucl)
		uclient_free(ucl);

	if (dlh)
		dlclose(dlh);

	if (rc)
		fprintf(stderr, "%s (%d)\n", strerror(-1 * rc), -1 * rc);

	return rc;
}
