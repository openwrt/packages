// implement *some* <regex> functions using pcre for performance:

#ifndef __REGEXP_PCRE_HPP
#define __REGEXP_PCRE_HPP

#include <pcre.h>
#include <string>
#include <iostream>


class regex {
public:
    regex(const std::string & str) 
    : re{ pcre_compile(str.c_str(), 0, &errp, &erroffs, NULL) }
    {
        if (re==NULL) {
            std::cerr<<"Regex error: "<<errp<<std::endl;
            std::cerr<<'\t'<<str<<std::endl;
            std::cerr<<'\t';
            while (--erroffs) { std::cerr<<' '; }
            std::cerr<<'^'<<std::endl;
        }
    }
    
    ~regex() { if (re) { pcre_free(re); } }
    
    inline const pcre * operator()() const { return re; }
    
private:
    const char * errp;
    int erroffs;
    pcre * const re;
};

bool regex_search(const std::string & subj, const regex & rgx);
bool regex_search(const std::string & subj, const regex & rgx) {
    int n = pcre_exec(rgx(), NULL, subj.c_str(), subj.length(), 0, 0, NULL, 0);
    return n>=0;
}

class smatch {
public:    
    auto position(int i=0) const { 
        return (i<0 || i>=n) ? std::string::npos : vec[2*i];
    }
    
    auto length(int i=0) const {
        return (i<0 || i>=n) ? 0 : vec[2*i+1] - vec[2*i];
    }
    
    std::string str(int i=0) const { // should we throw errors?
        if (i<0 || i>=n) { return ""; }
        int x = vec[2*i];
        if (x<0) { return ""; }
        int y = vec[2*i+1];
        return std::string(begin + x, begin + y); 
    }
    
    size_t size() const { return n; }
    
    bool empty() const { return n<0; }
    
    bool ready() const { return vec!=NULL; }
    
    ~smatch() { if (vec) { delete [] vec; } }
    
    // The following would have to use ssub_match:
//     std::string suffix() const {
//     }
//     std::string prefix() const {
//     }
//     std::string operator[](int i) const  {
//     }
    
    friend bool regex_search(const std::string::const_iterator begin,
                             const std::string::const_iterator end,
                             smatch & match, const regex & rgx);
private: 
    std::string::const_iterator begin;
    std::string::const_iterator end;
    int pos = 0;
    int * vec = NULL;
    int n = 0;
};

bool regex_search(const std::string::const_iterator begin, 
                  const std::string::const_iterator end,
                  smatch & match, const regex & rgx);
bool regex_search(const std::string::const_iterator begin, 
                  const std::string::const_iterator end,
                  smatch & match, const regex & rgx) {
    if (rgx()==NULL) {
        
    } else {
        if (match.vec) { delete [] match.vec; }
        size_t sz = 0;
        pcre_fullinfo(rgx(), NULL, PCRE_INFO_CAPTURECOUNT, &sz);
        sz = 3*(sz + 1);
        match.vec = new int[sz];
        match.begin = begin;
        match.end = end;
        const char * subj = &*begin;
        size_t len = &*end - subj;
        match.n = pcre_exec(rgx(), NULL, subj, len, 
                            match.pos, 0, match.vec, sz);
        if (match.n<0) { return false; }
        if (match.n==0) { match.n = sz/3; }
    }
    return true;
}


inline void __append_capture_(const char subj[], const int vec[], const int num,
                              std::string & ret, const int i)
{
    int pos = vec[2*i];
    int len = vec[2*i+1] - pos;
    ret.append(&subj[pos], len);
}
    
void _append_with_captures(const char subj[], const int vec[], const int num,
                      std::string & ret, const std::string & str);
void _append_with_captures(const char subj[], const int vec[], const int num, 
                      std::string & ret, const std::string & str)
{
    size_t index = 0;
    size_t pos;
    while ((pos=str.find('$', index)) != std::string::npos) {
        ret.append(str, index, pos-index);
        index = pos+1;
        char chr = str[index++];
        int n = 0;
        switch(chr) {
            case '&': // whole
                __append_capture_(subj, vec, num, ret, 0);
                break;
            case '`': // prefix
                ret.append(subj, vec[0]);
                break;
            case '\'': // suffix
                ret.append(&subj[vec[1]]);
                break;
            default: // number
                while (isdigit(chr)) {
                    n = 10*n + chr - '0';
                    chr = str[index++];
                }
                if (n>0 && n<num) { 
                    __append_capture_(subj, vec, num, ret, n);
                } else { ret += '$'; }
                [[fallthrough]];
            case '$': // escaped
                ret += chr;
        }
    }
    ret.append(str, index);
}

std::string regex_replace(const std::string & subj, 
                     const regex & rgx, 
                     const std::string & insert);
std::string regex_replace(const std::string & subj, 
                          const regex & rgx, 
                          const std::string & insert)
{
    std::string ret = "";
    const char * const str = subj.c_str();
    if (rgx()==NULL) {
        
    } else {
        size_t sz = 0;
        pcre_fullinfo(rgx(), NULL, PCRE_INFO_CAPTURECOUNT, &sz);
        sz = 3*(sz + 1);
        int * vec = new int[sz];
        size_t len = subj.length();
        size_t pos = 0;
        while (pos<len) {
            int n = pcre_exec(rgx(), NULL, str, len, pos, 0, vec, sz);
            if (n < 0) { break; }
            if (n==0) { n = sz/3; } // not all captures stored.
            ret.append(subj, pos, vec[0]-pos);
            _append_with_captures(str, vec, n, ret, insert);
            pos = vec[1];
        }
        ret.append(subj, pos);
        delete [] vec;
    }
//     std::cout<<ret<<std::endl;
    return ret;
}

#endif
