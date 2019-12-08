 
#ifndef __COMMON_H
#define __COMMON_H

#include <iostream>
#include <string>
#include <fstream>
#include <unistd.h>


void write_file(const std::string & filename, const std::string str,
                std::ios_base::openmode flag=std::ios::trunc);


std::string read_file(const std::string & filename);


int call(const char program[], const char arg[]);



void write_file(const std::string & filename, const std::string str,
                std::ios_base::openmode flag)
{
    std::ofstream file (filename, std::ios::out|flag);
    if (file.good()) { file<<str<<std::endl; }
    file.close();
}


std::string read_file(const std::string & filename)
{
    std::ifstream file(filename, std::ios::in|std::ios::ate);
    std::string str = "";
    if (file.good()) {
        size_t size = file.tellg();
        str.reserve(size);
        file.seekg(0);
        str.assign((std::istreambuf_iterator<char>(file)),
                std::istreambuf_iterator<char>());
    }
    file.close();
    return str;
}


int call(const char program[], const char arg[])
{
    pid_t pid = fork();
    switch(pid) {
        case -1: // could not fork.
            return -1;
        case 0: // child, exec never returns.
            execl(program, program, arg, (char *)NULL);
            exit(EXIT_FAILURE);
        default: //parent
            return pid;
    }
}


#endif
