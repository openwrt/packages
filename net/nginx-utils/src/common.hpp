 
#ifndef __COMMON_H
#define __COMMON_H

#include <iostream>
#include <string>
#include <fstream>


std::string read_file(const std::string & filename);
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

void write_file(const std::string & filename, const std::string str,
                std::ios_base::openmode flag=std::ios::trunc);
void write_file(const std::string & filename, const std::string str,
                std::ios_base::openmode flag)
{
    std::ofstream file (filename, std::ios::out|flag);
    if (file.good()) { file<<str<<std::endl; }
    file.close();
}

#endif
