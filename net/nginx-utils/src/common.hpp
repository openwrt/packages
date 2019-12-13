
#ifndef __COMMON_H
#define __COMMON_H

#include <iostream>
#include <string>
#include <fstream>
#include <unistd.h>
#include <cerrno>
#include <cstring>


// mode: optional ios::binary and/or ios::app (default ios::trunc)
void write_file(const std::string & name, const std::string str,
                const std::ios_base::openmode mode=std::ios::trunc);


// mode: optional ios::binary (internally ios::ate|ios::in)
std::string read_file(const std::string & name,
                      const std::ios_base::openmode mode=std::ios::in);


// all S must be convertible to const char[]
template<typename ...S>
pid_t call(const char program[], S... args);



// ------------------------- implementation: ----------------------------------


void write_file(const std::string & name, const std::string str,
                const std::ios_base::openmode flag)
{
    std::ofstream file(name, flag);
    if (!file.good()) {
        throw std::ofstream::failure("write_file error: cannot open " + name);
    }

    file<<str<<std::flush;

    file.close();
}


std::string read_file(const std::string & name,
                      const std::ios_base::openmode mode)
{
    std::ifstream file(name, mode|std::ios::ate);
    if (!file.good()) {
        throw std::ifstream::failure("read_file error: cannot open " + name);
    }

    std::string ret{};
    const size_t size = file.tellg();
    ret.reserve(size);

    file.seekg(0);
    ret.assign((std::istreambuf_iterator<char>(file)),
                std::istreambuf_iterator<char>());

    file.close();
    return move(ret);
}


template<typename ...S>
pid_t call(const char program[], S... args)
{
    pid_t pid = fork();

    if (pid==0) { //child:
        execl(program, program, args..., (char*)NULL);
        _exit(EXIT_FAILURE);  // exec never returns.
    } else if (pid>0) { //parent:
        return pid;
    }

    std::string errmsg = "call error: cannot fork (";
    errmsg += std::to_string(errno) + "): " + std::strerror(errno);
    throw std::runtime_error(errmsg.c_str());
}


#endif
