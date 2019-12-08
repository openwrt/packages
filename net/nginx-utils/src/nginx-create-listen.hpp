
#ifndef __NGINX_CREATE_LISTEN_H
#define __NGINX_CREATE_LISTEN_H

#include <string>
#include <functional>

#ifdef openwrt
extern "C" {
#include <libubus.h>
}
#endif

#include "common.hpp"

using namespace std; 

static const string LAN_LISTEN = "/var/lib/nginx/lan.listen";
static const string LAN_SSL_LISTEN = "/var/lib/nginx/lan_ssl.listen";


#ifdef openwrt


void ubus_traverse(const blob_attr * attr, function<void(void * val)> process);


void create_lan_listen_callback(ubus_request * req, int type, blob_attr * msg);


template<class T, class ... Types>
void ubus_traverse(const blob_attr * attr, function<void(void * val)> process,
                   T key, Types ... keys);


static int create_lan_listen();


void ubus_traverse(const blob_attr * attr, function<void(void * val)> process)
{}


template<class T, class ... Types>
void ubus_traverse(const blob_attr * attr, function<void(void * val)> process,
                   T key, Types ... keys)
{
    blob_attr * pos;
    size_t len;
    blobmsg_for_each_attr(pos, attr, len) {
        const char * name = blobmsg_name(pos);
        if (name != (string)"" && name != (string)key) { continue; }
        switch (blob_id(pos)) {
            case BLOBMSG_TYPE_TABLE: [[fallthrough]]
            case BLOBMSG_TYPE_ARRAY:
                    name==(string)key ? ubus_traverse(pos, process, keys...)
                            : ubus_traverse(pos, process, key, keys...);
                break;
            default:
                if (sizeof...(keys)==0 && (string)key==name) {
                    process(blobmsg_data(pos));
                }
        }
    }
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
        &ssl_listen_default, suffix, prefix] (void * val) -> void
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
    ubus_traverse(msg, create_it, "ipv4-address", "address");
    prefix = "[";
    suffix = "]";
    ubus_traverse(msg, create_it, "ipv6-address", "address");

    listen += "\tlisten 127.0.0.1:80;\n";
    listen += "\tlisten [::1]:80;\n";
    listen_default += "\tlisten 127.0.0.1:80 default_server;\n";
    listen_default += "\tlisten [::1]:80 default_server;\n";
    ssl_listen += "\tlisten 127.0.0.1:443 ssl;\n";
    ssl_listen += "\tlisten [::1]:443 ssl;\n";
    ssl_listen_default += "\tlisten 127.0.0.1:443 ssl default_server;\n";
    ssl_listen_default += "\tlisten [::1]:443 ssl default_server;\n";
    write_file(LAN_LISTEN, listen);
    write_file(LAN_LISTEN+".default", listen_default);
    write_file(LAN_SSL_LISTEN, ssl_listen);
    write_file(LAN_SSL_LISTEN+".default", ssl_listen_default);
}


static int create_lan_listen()
{
    ubus_context * ctx = ubus_connect(NULL);
    if (ctx==NULL) { return -1; }
    uint32_t id;
    int ret = ubus_lookup_id(ctx, "network.interface.lan", &id);
    if (ret==0) {
        static blob_buf req;
        blob_buf_init(&req, 0);
        ret = ubus_invoke(ctx, id, "status", req.head,
                          create_lan_listen_callback, NULL, 200);
    }
    if (ctx) { ubus_free(ctx); }
    return ret;
}


#endif


#endif
