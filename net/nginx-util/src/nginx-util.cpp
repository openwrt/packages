// This file is included in nginx-ssl-util.cpp, which defines NGINX_OPENSSL.
#ifndef __NGINX_UTIL_C
#define __NGINX_UTIL_C

#include "nginx-util.hpp"


void create_lan_listen()
{
    std::string listen = "# This file is re-created if Nginx starts or"
                    " a LAN address changes.\n";
    std::string listen_default = listen;
    std::string ssl_listen = listen;
    std::string ssl_listen_default = listen;

    auto add_listen = [&listen, &listen_default
#ifdef NGINX_OPENSSL
                       ,&ssl_listen, &ssl_listen_default
#endif
                      ]
        (const std::string &pre, const std::string &ip, const std::string &suf)
        -> void
    {
        if (ip.empty()) { return; }
        const std::string val = pre + ip + suf;
        listen += "\tlisten " + val + ":80;\n";
        listen_default += "\tlisten " + val + ":80 default_server;\n";
#ifdef NGINX_OPENSSL
        ssl_listen += "\tlisten " + val + ":443 ssl;\n";
        ssl_listen_default += "\tlisten " + val + ":443 ssl default_server;\n";
#endif
    };

    add_listen("", "127.0.0.1", "");
    add_listen("[", "::1", "]");

#ifndef NO_UBUS
    auto lan_status = ubus::call("network.interface.lan", "status");

    for (auto ip : lan_status.filter("ipv4-address", "", "address")) {
        add_listen("",  static_cast<const char *>(blobmsg_data(ip)), "");
    }

    for (auto ip : lan_status.filter("ipv6-address", "", "address")) {
        add_listen("[", static_cast<const char *>(blobmsg_data(ip)), "]");
    }
#endif

    write_file(LAN_LISTEN, listen);
    write_file(LAN_LISTEN_DEFAULT, listen_default);
#ifdef NGINX_OPENSSL
    write_file(LAN_SSL_LISTEN, ssl_listen);
    write_file(LAN_SSL_LISTEN_DEFAULT, ssl_listen_default);
#endif
}


void init_lan()
{
    std::exception_ptr ex;

#ifdef NGINX_OPENSSL
    auto thrd = std::thread([&ex]{
       try { add_ssl_if_needed(std::string{LAN_NAME}); }
        catch (...) {
            std::cerr<<"init_lan error: cannot add SSL for "<<LAN_NAME<<std::endl;
            ex = std::current_exception();
        }
    });
#endif

    try { create_lan_listen(); }
    catch (...) {
        std::cerr<<"init_lan error: cannot create LAN listen directives"<<std::endl;
        ex = std::current_exception();
    }

#ifdef NGINX_OPENSSL
    thrd.join();
#endif

    if (ex) { std::rethrow_exception(ex); }
}


void get_env()
{
    std::cout<<"NGINX_CONF="<<"'"<<NGINX_CONF<<"'"<<std::endl;
    std::cout<<"CONF_DIR="<<"'"<<CONF_DIR<<"'"<<std::endl;
    std::cout<<"LAN_NAME="<<"'"<<LAN_NAME<<"'"<<std::endl;
    std::cout<<"LAN_LISTEN="<<"'"<<LAN_LISTEN<<"'"<<std::endl;
#ifdef NGINX_OPENSSL
    std::cout<<"LAN_SSL_LISTEN="<<"'"<<LAN_SSL_LISTEN<<"'"<<std::endl;
    std::cout<<"SSL_SESSION_CACHE_ARG="<<"'"<<SSL_SESSION_CACHE_ARG(LAN_NAME)<<
        "'"<<std::endl;
    std::cout<<"SSL_SESSION_TIMEOUT_ARG="<<"'"<<SSL_SESSION_TIMEOUT_ARG<<"'\n";
    std::cout<<"ADD_SSL_FCT="<<"'"<<ADD_SSL_FCT<<"'"<<std::endl;
#endif
}


auto main(int argc, char * argv[]) -> int
{
    // TODO(pst): use std::span when available:
    auto args = std::basic_string_view{argv, static_cast<size_t>(argc)};

    auto cmds = std::array{
        std::array<std::string_view, 2>{"init_lan", ""},
        std::array<std::string_view, 2>{"get_env", ""},
#ifdef NGINX_OPENSSL
        std::array<std::string_view, 2>{ADD_SSL_FCT, " server_name" },
        std::array<std::string_view, 2>{"del_ssl", " server_name" },
#endif
    };

    try {

        if (argc==2 && args[1]==cmds[0][0]) { init_lan(); }

        else if (argc==2 && args[1]==cmds[1][0]) { get_env(); }

#ifdef NGINX_OPENSSL
        else if (argc==3 && args[1]==cmds[2][0])
        { add_ssl_if_needed(std::string{args[2]});}

        else if (argc==3 && args[1]==cmds[3][0])
        { del_ssl(std::string{args[2]}); }

        else if (argc==2 && args[1]==cmds[3][0])
        { del_ssl(std::string{LAN_NAME}); }
#endif

        else {
            auto usage = std::string{"usage: "} + *argv + " [";
            for (auto cmd : cmds) {
                usage += std::string{cmd[0]};
                usage += std::string{cmd[1]} + "|";
            }
            usage[usage.size()-1] = ']';

            std::cerr<<usage<<std::endl;

            throw std::runtime_error("main error: argument not recognized");
        }

        return 0;

    }

    catch (const std::exception & e) { std::cerr<<e.what()<<std::endl; }

    catch (...) { perror("main error"); }

    return 1;

}

#endif
