// SPDX-License-Identifier: LGPL-2.1+
// Copyright (C) 2023 Andre Heider <a.heider@gmail.com>

#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <net/if.h>
#include <netdb.h>
#include <stdio.h>
#include <string.h>

#include <libubox/blobmsg.h>
#include <libubox/blobmsg_json.h>

#include <libubus.h>

#include <rpcd/plugin.h>

#include "wireguard.h"

static struct blob_buf buf;

enum {
	RPC_PK_DEVICE,
	__RPC_PK_MAX,
};

static const struct blobmsg_policy rpc_privatekey_policy[__RPC_PK_MAX] = {
	[RPC_PK_DEVICE] = { .name = "private", .type = BLOBMSG_TYPE_STRING },
};

static void rpc_wireguard_add_endpoint(const wg_endpoint *endpoint)
{
	char host[1025]; // NI_MAXHOST
	char serv[32]; // NI_MAXSERV
	char res[sizeof(host) + sizeof(serv) + 4];
	socklen_t addr_len;

	memset(res, 0, sizeof(res));
	if (endpoint->addr.sa_family == AF_INET)
		addr_len = sizeof(struct sockaddr_in);
	else if (endpoint->addr.sa_family == AF_INET6)
		addr_len = sizeof(struct sockaddr_in6);
	else
		return;

	if (getnameinfo(&endpoint->addr, addr_len, host, sizeof(host), serv, sizeof(serv),
			NI_DGRAM | NI_NUMERICHOST | NI_NUMERICSERV))
		return;

	if (endpoint->addr.sa_family == AF_INET6 && strchr(host, ':'))
		snprintf(res, sizeof(res), "[%s]:%s", host, serv);
	else
		snprintf(res, sizeof(res), "%s:%s", host, serv);
	res[sizeof(res) - 1] = 0;

	blobmsg_add_string(&buf, "endpoint", res);
}

static void rpc_wireguard_add_allowedip(const wg_allowedip *allowedip)
{
	char res[INET6_ADDRSTRLEN + 4 + 1];

	memset(res, 0, sizeof(res));
	if (allowedip->family == AF_INET)
		inet_ntop(AF_INET, &allowedip->ip4, res, INET6_ADDRSTRLEN);
	else if (allowedip->family == AF_INET6)
		inet_ntop(AF_INET6, &allowedip->ip6, res, INET6_ADDRSTRLEN);
	else
		return;

	if (!res[0])
		return;

	sprintf(res + strlen(res), "/%u", allowedip->cidr);
	res[sizeof(res) - 1] = 0;

	blobmsg_add_string(&buf, NULL, res);
}

static void rpc_wireguard_add_peer(const wg_peer *peer)
{
	void *c;
	struct wg_allowedip *allowedip;

	rpc_wireguard_add_endpoint(&peer->endpoint);

	c = blobmsg_open_array(&buf, "allowed_ips");
	wg_for_each_allowedip(peer, allowedip)
		rpc_wireguard_add_allowedip(allowedip);
	blobmsg_close_array(&buf, c);

	blobmsg_add_u64(&buf, "last_handshake", peer->last_handshake_time.tv_sec);
	blobmsg_add_u64(&buf, "rx_bytes", peer->rx_bytes);
	blobmsg_add_u64(&buf, "tx_bytes", peer->tx_bytes);
	if (peer->persistent_keepalive_interval)
		blobmsg_add_u16(&buf, "persistent_keepalive_interval", peer->persistent_keepalive_interval);
}

static void rpc_wireguard_add_device(const wg_device *device)
{
	void *c, *d;
	wg_peer *peer;
	wg_key_b64_string key;

	blobmsg_add_u32(&buf, "ifindex", device->ifindex);

	if (device->flags & WGDEVICE_HAS_PUBLIC_KEY) {
		wg_key_to_base64(key, device->public_key);
		blobmsg_add_string(&buf, "public_key", key);
	}

	if (device->listen_port)
		blobmsg_add_u16(&buf, "listen_port", device->listen_port);

	if (device->fwmark)
		blobmsg_add_u32(&buf, "fwmark", device->fwmark);

	c = blobmsg_open_table(&buf, "peers");
	wg_for_each_peer(device, peer) {
		wg_key_to_base64(key, peer->public_key);
		d = blobmsg_open_table(&buf, key);
		rpc_wireguard_add_peer(peer);
		blobmsg_close_table(&buf, d);
	}
	blobmsg_close_table(&buf, c);
}

static int rpc_wireguard_status(struct ubus_context *ctx, struct ubus_object *obj,
	struct ubus_request_data *req, const char *method, struct blob_attr *msg)
{
	void *c;
	char *device_names, *device_name;
	size_t len;

	device_names = wg_list_device_names();
	if (!device_names)
		return UBUS_STATUS_NOT_FOUND;

	blob_buf_init(&buf, 0);

	wg_for_each_device_name(device_names, device_name, len) {
		wg_device *device;

		if (wg_get_device(&device, device_name) < 0)
			continue;

		c = blobmsg_open_table(&buf, device_name);
		rpc_wireguard_add_device(device);
		blobmsg_close_table(&buf, c);

		wg_free_device(device);
	}

	free(device_names);

	ubus_send_reply(ctx, req, buf.head);

	return UBUS_STATUS_OK;
}

static int rpc_wireguard_genkey(struct ubus_context *ctx, struct ubus_object *obj,
	struct ubus_request_data *req, const char *method, struct blob_attr *msg)
{
	wg_key private_key, public_key;
	wg_key_b64_string key;

	wg_generate_private_key(private_key);
	wg_generate_public_key(public_key, private_key);

	blob_buf_init(&buf, 0);
	wg_key_to_base64(key, private_key);
	blobmsg_add_string(&buf, "private", key);
	wg_key_to_base64(key, public_key);
	blobmsg_add_string(&buf, "public", key);
	ubus_send_reply(ctx, req, buf.head);

	return UBUS_STATUS_OK;
}

static int rpc_wireguard_genpsk(struct ubus_context *ctx, struct ubus_object *obj,
	struct ubus_request_data *req, const char *method, struct blob_attr *msg)
{
	wg_key preshared_key;
	wg_key_b64_string key;

	wg_generate_preshared_key(preshared_key);

	blob_buf_init(&buf, 0);
	wg_key_to_base64(key, preshared_key);
	blobmsg_add_string(&buf, "preshared", key);
	ubus_send_reply(ctx, req, buf.head);

	return UBUS_STATUS_OK;
}

static int rpc_wireguard_pubkey(struct ubus_context *ctx, struct ubus_object *obj,
	struct ubus_request_data *req, const char *method, struct blob_attr *msg)
{
	static struct blob_attr *tb[__RPC_PK_MAX];
	wg_key_b64_string key;
	wg_key private_key, public_key;

	blobmsg_parse(rpc_privatekey_policy, __RPC_PK_MAX, tb, blob_data(msg), blob_len(msg));

	if (!tb[RPC_PK_DEVICE])
		return UBUS_STATUS_INVALID_ARGUMENT;

	if (wg_key_from_base64(private_key, blobmsg_get_string(tb[RPC_PK_DEVICE])))
		return UBUS_STATUS_INVALID_ARGUMENT;

	wg_generate_public_key(public_key, private_key);
	blob_buf_init(&buf, 0);
	wg_key_to_base64(key, public_key);
	blobmsg_add_string(&buf, "public", key);
	ubus_send_reply(ctx, req, buf.head);

	return UBUS_STATUS_OK;
}

static int rpc_wireguard_api_init(const struct rpc_daemon_ops *ops, struct ubus_context *ctx)
{
	static const struct ubus_method wireguard_methods[] = {
		UBUS_METHOD_NOARG("status", rpc_wireguard_status),
		UBUS_METHOD_NOARG("genkey", rpc_wireguard_genkey),
		UBUS_METHOD_NOARG("genpsk", rpc_wireguard_genpsk),
		UBUS_METHOD("pubkey", rpc_wireguard_pubkey, rpc_privatekey_policy),
	};

	static struct ubus_object_type wireguard_type =
		UBUS_OBJECT_TYPE("rpcd-plugin-wireguard", wireguard_methods);

	static struct ubus_object obj = {
		.name = "wireguard",
		.type = &wireguard_type,
		.methods = wireguard_methods,
		.n_methods = ARRAY_SIZE(wireguard_methods),
	};

	return ubus_add_object(ctx, &obj);
}

struct rpc_plugin rpc_plugin = {
	.init = rpc_wireguard_api_init
};
