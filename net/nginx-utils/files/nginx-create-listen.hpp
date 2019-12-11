
#ifndef __NGINX_CREATE_LISTEN_H
#define __NGINX_CREATE_LISTEN_H

#include <string>

#ifdef openwrt
#include <functional>
#include <string.h>
extern "C" {
#include <libubus.h>
}
#endif

#include "common.hpp"

using namespace std;

static const string LAN_LISTEN = "/var/lib/nginx/lan.listen";
static const string LAN_SSL_LISTEN = "/var/lib/nginx/lan_ssl.listen";


#ifdef openwrt


// ubus_traverse walks the msg tree and processes values for matching keys:
// msg = message that ubus sent to a callback function set up by ubus_invoke.
// process = function to which values are send if all the following keys match.
// key, ... keys = match the keys of the msg tree in the given order; we are at
//   the end if there is only one key left, do nothing if there is none.
// (Works if the number of keys is known at compile time, else use valist ...)

void ubus_traverse(const blob_attr * msg,
                   function<void(const void * val)> process);

template<class T, class ... Types>
void ubus_traverse(const blob_attr * msg,
                   function<void(const void * val)> process,
                   T key, Types ... keys);


static int ubus_call(const char * path, const char * method,
                     ubus_data_handler_t callback);


void create_lan_listen_callback(ubus_request * req, int type, blob_attr * msg);



// --------------------------- implement --------------------------------------


void ubus_traverse(const blob_attr * msg,
                   function<void(const void * val)> process)
{}

template<class T, class ... Types>
void ubus_traverse(const blob_attr * msg,
                   function<void(const void * val)> process,
                   T key, Types ... keys)
{
    size_t len;
    blob_attr * pos;
    blobmsg_for_each_attr(pos, msg, len) {
        const char * name = blobmsg_name(pos);
        if (strcmp(name, key) != 0) { continue; }
        switch (blob_id(pos)) {
            case BLOBMSG_TYPE_TABLE: [[fallthrough]]
            case BLOBMSG_TYPE_ARRAY: ubus_traverse(pos, process, keys...);
            break;
            default: if (sizeof...(keys)==0) { process(blobmsg_data(pos)); }
        }
    }
}


static int ubus_call(const char * path, const char * method,
                     ubus_data_handler_t callback)
{
    ubus_context * ctx = ubus_connect(NULL);
    if (ctx==NULL) { return -1; }
    uint32_t id;
    int ret = ubus_lookup_id(ctx, path, &id);
    if (ret==0) {
        static blob_buf req;
        blob_buf_init(&req, 0);
        int timeout = 200;
        ret = ubus_invoke(ctx, id, method, req.head, callback, NULL, timeout);
    }
    if (ctx) { ubus_free(ctx); }
    return ret;
}

void create_lan_listen_callback(ubus_request * req, int type, blob_attr * msg)
{
    if (!msg) { return; }

    string listen = "# This file is re-created if Nginx starts or"
        " a LAN address changes.\n";
    string listen_default = listen;
    string ssl_listen = listen;
    string ssl_listen_default = listen;

    string prefix;
    string suffix;
    auto create_it = [&listen, &listen_default, &ssl_listen,
        &ssl_listen_default, &suffix, &prefix] (const void * val) -> void
    {
        string ip = (char *)val;
        if (ip == "") { return; }
        ip = prefix + ip + suffix;
        listen += "\tlisten " + ip + ":80;\n";
        listen_default += "\tlisten " + ip + ":80 default_server;\n";
        ssl_listen += "\tlisten " + ip + ":443 ssl;\n";
        ssl_listen_default += "\tlisten " + ip + ":443 ssl default_server;\n";
    };

    prefix = "";
    suffix = "";
    ubus_traverse(msg, create_it, "ipv4-address", "", "address");
    create_it("127.0.0.1");

    prefix = "[";
    suffix = "]";
    ubus_traverse(msg, create_it, "ipv6-address", "", "address");
    create_it("::1");
    
    write_file(LAN_LISTEN, listen);
    write_file(LAN_LISTEN+".default", listen_default);
    write_file(LAN_SSL_LISTEN, ssl_listen);
    write_file(LAN_SSL_LISTEN+".default", ssl_listen_default);
}


#endif


#endif
