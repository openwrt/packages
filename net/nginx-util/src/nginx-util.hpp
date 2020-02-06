#ifndef __NGINX_UTIL_H
#define __NGINX_UTIL_H

#include <array>
#include <cerrno>
#include <cstdio>
#include <cstring>
#include <fstream>
#include <iostream>
#include <string>
#include <string_view>
#include <unistd.h>

#ifndef NO_UBUS
#include "ubus-cxx.hpp"
#endif


static constexpr auto NGINX_UTIL = std::string_view{"/usr/bin/nginx-util"};

static constexpr auto NGINX_CONF = std::string_view{"/etc/nginx/nginx.conf"};

static constexpr auto CONF_DIR = std::string_view{"/etc/nginx/conf.d/"};

static constexpr auto LAN_NAME = std::string_view{"_lan"};

static constexpr auto LAN_LISTEN =std::string_view{"/var/lib/nginx/lan.listen"};

static constexpr auto LAN_LISTEN_DEFAULT =
    std::string_view{"/var/lib/nginx/lan.listen.default"};


// mode: optional ios::binary and/or ios::app (default ios::trunc)
void write_file(const std::string_view & name, const std::string & str,
                std::ios_base::openmode flag=std::ios::trunc);


// mode: optional ios::binary (internally ios::ate|ios::in)
auto read_file(const std::string_view & name,
                      std::ios_base::openmode mode=std::ios::in) -> std::string;


// all S must be convertible to const char[]
template<typename ...S>
auto call(const std::string & program, S... args) -> pid_t;


void create_lan_listen();


void init_lan();


void get_env();



// --------------------- partial implementation: ------------------------------


void write_file(const std::string_view & name, const std::string & str,
                const std::ios_base::openmode flag)
{
    std::ofstream file(name.data(), flag);
    if (!file.good()) {
        throw std::ofstream::failure(
            "write_file error: cannot open " + std::string{name});
    }

    file<<str<<std::flush;

    file.close();
}


auto read_file(const std::string_view & name,
                      const std::ios_base::openmode mode) -> std::string
{
    std::ifstream file(name.data(), mode|std::ios::ate);
    if (!file.good()) {
        throw std::ifstream::failure(
            "read_file error: cannot open " + std::string{name});
    }

    std::string ret{};
    const size_t size = file.tellg();
    ret.reserve(size);

    file.seekg(0);
    ret.assign((std::istreambuf_iterator<char>(file)),
                std::istreambuf_iterator<char>());

    file.close();
    return ret;
}


template<typename ...S>
auto call(const char * program, S... args) -> pid_t
{
    pid_t pid = fork();

    if (pid==0) { //child:
        std::array<char *, sizeof...(args)+2> argv =
        { strdup(program), strdup(args)..., nullptr };

        execv(program, argv.data()); // argv cannot be const char * const[]!

        _exit(EXIT_FAILURE);  // exec never returns.
    } else if (pid>0) { //parent:
        return pid;
    }

    std::string errmsg = "call error: cannot fork (";
    errmsg += std::to_string(errno) + "): " + std::strerror(errno);
    throw std::runtime_error(errmsg.c_str());
}


#endif
