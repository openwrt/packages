#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/select.h>

#include <libubox/blob.h>
#include <libubox/blobmsg.h>
#include <libubus.h>

#include <arpa/inet.h>
#include <net/if.h>
#include <netinet/in.h>
#include <sys/ioctl.h>
#include <sys/socket.h>

#include "defs.h"
#include "ifnet.h"
#include "interfaces.h"
#include "link_set.h"
#include "log.h"
#include "olsr.h"
#include "olsr_cfg.h"

#include "ubus.h"

#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define MIN(a, b) ((a) < (b) ? (a) : (b))

// Shared state maintained throughout calls to handle ubus messages.
static struct ubus_context *shared_ctx;

enum { INTERFACE_IFNAME, INTERFACE_LQM, __INTERFACE_MAX };

static const struct blobmsg_policy interface_policy[__INTERFACE_MAX] = {
    [INTERFACE_IFNAME] = {"ifname", BLOBMSG_TYPE_STRING},
    [INTERFACE_LQM] = {"lqm", BLOBMSG_TYPE_STRING},
};

static int olsrd_ubus_add_interface(struct ubus_context *ctx_local,
                                    struct ubus_object *obj,
                                    struct ubus_request_data *req,
                                    const char *method, struct blob_attr *msg) {
  struct blob_attr *tb[__INTERFACE_MAX];
  struct blob_buf b = {0};
  union olsr_ip_addr addr;
  int ret;
  char *ifname, *lqm;

  blobmsg_parse(interface_policy, __INTERFACE_MAX, tb, blob_data(msg),
                blob_len(msg));

  if (!tb[INTERFACE_IFNAME])
    return UBUS_STATUS_INVALID_ARGUMENT;

  ifname = blobmsg_get_string(tb[INTERFACE_IFNAME]);

  struct interface_olsr *tmp = if_ifwithname(ifname);
  if (tmp != NULL) {
    return UBUS_STATUS_PERMISSION_DENIED;
  }

  struct olsr_if *temp;
  for (temp = olsr_cnf->interfaces; temp != NULL; temp = temp->next) {
    if (strcmp(temp->name, ifname) == 0)
      return UBUS_STATUS_PERMISSION_DENIED;
  }

  struct olsr_if *tmp_ifs = olsr_create_olsrif(ifname, false);
  tmp_ifs->cnf =
      olsr_malloc(sizeof(struct if_config_options), "Set default config");
  *tmp_ifs->cnf = *olsr_cnf->interface_defaults;

  if (tb[INTERFACE_LQM]) { // add interface lqm
    lqm = blobmsg_get_string(tb[INTERFACE_LQM]);
    memset(&addr, 0, sizeof(addr));

    struct olsr_lq_mult *mult = malloc(sizeof(*mult));
    if (mult == NULL) {
      olsr_syslog(OLSR_LOG_ERR, "Out of memory (LQ multiplier).\n");
      return UBUS_STATUS_UNKNOWN_ERROR;
    }

    double lqm_value = atof(lqm);
    mult->addr = addr;
    mult->value = (uint32_t)(lqm_value * LINK_LOSS_MULTIPLIER);
    tmp_ifs->cnf->lq_mult = mult;
    tmp_ifs->cnf->orig_lq_mult_cnt++;
  }

  blob_buf_init(&b, 0);
  blobmsg_add_string(&b, "adding", ifname);

  ret = ubus_send_reply(ctx_local, req, b.head);
  if (ret)
    olsr_syslog(OLSR_LOG_ERR, "Failed to send reply: %s\n", ubus_strerror(ret));

  blob_buf_free(&b);

  return ret;
}

static int olsrd_ubus_del_interface(struct ubus_context *ctx_local,
                                    struct ubus_object *obj,
                                    struct ubus_request_data *req,
                                    const char *method, struct blob_attr *msg) {
  struct blob_attr *tb[__INTERFACE_MAX];
  struct blob_buf b = {0};
  int ret;
  char *ifname;
  struct olsr_if *tmp_if, *del_if;

  blobmsg_parse(interface_policy, __INTERFACE_MAX, tb, blob_data(msg),
                blob_len(msg));

  if (!tb[INTERFACE_IFNAME])
    return UBUS_STATUS_INVALID_ARGUMENT;

  ifname = blobmsg_get_string(tb[INTERFACE_IFNAME]);

  struct interface_olsr *tmp = if_ifwithname(ifname);

  if (tmp != NULL) {

    struct olsr_if *temp = olsr_cnf->interfaces, *prev;
    if (temp != NULL && (strcmp(temp->name, ifname) == 0)) {
      olsr_cnf->interfaces = temp->next;
      olsr_remove_interface(temp);
      goto send_reply;
    }

    while (temp != NULL && (strcmp(temp->name, ifname) != 0)) {
      prev = temp;
      temp = temp->next;
    }

    if (temp == NULL) {
      goto send_reply;
    }

    prev->next = temp->next;
    olsr_remove_interface(temp);
  } else {
    return UBUS_STATUS_PERMISSION_DENIED;
  }

send_reply:

  blob_buf_init(&b, 0);
  blobmsg_add_string(&b, "deleting", ifname);

  ret = ubus_send_reply(ctx_local, req, b.head);
  if (ret)
    olsr_syslog(OLSR_LOG_ERR, "Failed to send reply: %s\n", ubus_strerror(ret));

  blob_buf_free(&b);

  return ret;
}

// List of functions we expose via the ubus bus.
static const struct ubus_method olsrd_methods[] = {
    UBUS_METHOD("add_interface", olsrd_ubus_add_interface, interface_policy),
    UBUS_METHOD("del_interface", olsrd_ubus_del_interface, interface_policy),
};

// Definition of the ubus object type.
static struct ubus_object_type olsrd_object_type =
    UBUS_OBJECT_TYPE("olsrd", olsrd_methods);

// Object we announce via the ubus bus.
static struct ubus_object olsrd_object = {
    .name = "olsrd",
    .type = &olsrd_object_type,
    .methods = olsrd_methods,
    .n_methods = ARRAY_SIZE(olsrd_methods),
};

// Registers handlers for olsrd methods in the global ubus context.
static bool ubus_init_object() {
  int ret;

  ret = ubus_add_object(shared_ctx, &olsrd_object);
  if (ret) {
    olsr_syslog(OLSR_LOG_ERR, "Failed to add object: %s\n", ubus_strerror(ret));
    return false;
  }

  return true;
}

// Initializes the global ubus context, connecting to the bus to be able to
// receive and send messages.
static bool olsrd_ubus_init(void) {
  if (shared_ctx)
    return true;

  shared_ctx = ubus_connect(NULL);
  if (!shared_ctx)
    return false;

  return true;
}

void olsrd_ubus_receive(fd_set *readfds) {
  if (!shared_ctx)
    return;
  if (FD_ISSET(shared_ctx->sock.fd, readfds))
    ubus_handle_event(shared_ctx);
}

int olsrd_ubus_add_read_sock(fd_set *readfds, int maxfd) {
  if (!shared_ctx)
    return maxfd;

  FD_SET(shared_ctx->sock.fd, readfds);
  return MAX(maxfd, shared_ctx->sock.fd + 1);
}

bool olsrd_add_ubus() {
  if (!olsrd_ubus_init()) {
    olsr_syslog(OLSR_LOG_ERR, "Failed to initialize ubus!\n");
    return false;
  }
  if (!ubus_init_object()) {
    olsr_syslog(OLSR_LOG_ERR, "Failed to add objects to ubus!\n");
    return false;
  }
  return true;
}
