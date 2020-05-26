#include <iostream>

#include "nginx-util.hpp"

#ifndef NO_SSL
#include "nginx-ssl-util.hpp"
#endif


void create_lan_listen()
{
    std::string listen = "# This file is re-created if Nginx starts or"
                    " a LAN address changes.\n";
    std::string listen_default = listen;
    std::string ssl_listen = listen;
    std::string ssl_listen_default = listen;

    auto add_listen = [&listen, &listen_default
#ifndef NO_SSL
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
#ifndef NO_SSL
        ssl_listen += "\tlisten " + val + ":443 ssl;\n";
        ssl_listen_default += "\tlisten " + val + ":443 ssl default_server;\n";
#endif
    };

#ifndef NO_UBUS
    try {
        auto loopback_status=ubus::call("network.interface.loopback", "status");

        for (auto ip : loopback_status.filter("ipv4-address", "", "address")) {
            add_listen("",  static_cast<const char *>(blobmsg_data(ip)), "");
        }

        for (auto ip : loopback_status.filter("ipv6-address", "", "address")) {
            add_listen("[", static_cast<const char *>(blobmsg_data(ip)), "]");
        }
    } catch (const std::runtime_error &) { /* do nothing about it */ }

    try {
        auto lan_status = ubus::call("network.interface.lan", "status");

        for (auto ip : lan_status.filter("ipv4-address", "", "address")) {
            add_listen("",  static_cast<const char *>(blobmsg_data(ip)), "");
        }

        for (auto ip : lan_status.filter("ipv6-address", "", "address")) {
            add_listen("[", static_cast<const char *>(blobmsg_data(ip)), "]");
        }

        for (auto ip : lan_status.filter("ipv6-prefix-assignment", "", 
            "local-address", "address"))
        {
            add_listen("[", static_cast<const char *>(blobmsg_data(ip)), "]");
        }
    } catch (const std::runtime_error &) { /* do nothing about it */ }
#else
    add_listen("", "127.0.0.1", "");
#endif

    write_file(LAN_LISTEN, listen);
    write_file(LAN_LISTEN_DEFAULT, listen_default);
#ifndef NO_SSL
    write_file(LAN_SSL_LISTEN, ssl_listen);
    write_file(LAN_SSL_LISTEN_DEFAULT, ssl_listen_default);
#endif
}


void init_lan()
{
    std::exception_ptr ex;

#ifndef NO_SSL
    auto thrd = std::thread([]{ //&ex
        try { add_ssl_if_needed(std::string{LAN_NAME}); }
        catch (...) {
            std::cerr<<"init_lan notice: no server named "<<LAN_NAME<<std::endl;
            // not: ex = std::current_exception();
        }
    });
#endif

    try { create_lan_listen(); }
    catch (...) {
        std::cerr<<"init_lan error: cannot create LAN listen files"<<std::endl;
        ex = std::current_exception();
    }

#ifndef NO_SSL
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
#ifndef NO_SSL
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
    auto args = std::basic_string_view<char *>{argv, static_cast<size_t>(argc)};

    auto cmds = std::array{
        std::array<std::string_view, 2>{"init_lan", ""},
        std::array<std::string_view, 2>{"get_env", ""},
#ifndef NO_SSL
        std::array<std::string_view, 2>{ADD_SSL_FCT, " server_name" },
        std::array<std::string_view, 2>{"del_ssl", " server_name" },
#endif
    };

    try {

        if (argc==2 && args[1]==cmds[0][0]) { init_lan(); }

        else if (argc==2 && args[1]==cmds[1][0]) { get_env(); }

#ifndef NO_SSL
        else if (argc==3 && args[1]==cmds[2][0])
        { add_ssl_if_needed(std::string{args[2]});}

        else if (argc==3 && args[1]==cmds[3][0])
        { del_ssl(std::string{args[2]}); }

        else if (argc==2 && args[1]==cmds[3][0])
        { del_ssl(std::string{LAN_NAME}); }
#endif

        else {
            std::cerr<<"Tool for creating Nginx configuration files (";
#ifdef VERSION
            std::cerr<<"version "<<VERSION<<" ";
#endif
            std::cerr<<"with ";
#ifndef NO_UBUS
            std::cerr<<"ubus, ";
#endif
#ifndef NO_SSL
            std::cerr<<"libopenssl, ";
#ifdef NO_PCRE
            std::cerr<<"std::regex, ";
#else
            std::cerr<<"PCRE, ";
#endif
#endif
            std::cerr<<"pthread and libstdcpp)."<<std::endl;

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
