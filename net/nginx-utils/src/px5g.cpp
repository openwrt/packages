

#include <string>
#include <stdexcept>
#include <iostream>
using namespace std;
#include "px5g-openssl.hpp"

int checkend(const char * argv[]);
int checkend(const char * argv[])
{
    bool use_pem = true;
    const char * infile = NULL;

    string arg = argv[0];
    size_t pos;
    intmax_t num;

    try {
        num = stoi(arg, &pos);
    } catch(const invalid_argument & e) {
        throw invalid_argument("checkend error: invalid number");
    } catch(const out_of_range & e) {
        throw out_of_range("checkend error: invalid number (out of range)");
    }

    if (pos < arg.size()) {
        throw runtime_error("checkend error: invalid number (trailing char)");
    }

    auto seconds = reinterpret_cast<time_t>(num);
    
    if (num!=(intmax_t)seconds) {
        throw runtime_error("checkend error: number too big for time");
    }

    for (++argv; argv[0] && argv[0][0]=='-'; ++argv) {
        if (argv[0]==string{"-in"}) {
            ++argv;
            
            if (!argv[0]) {
                throw runtime_error("checkend error: -in without filename");
            }
            
            if (infile) {
                throw runtime_error("checkend error: more than one -in file");
            }
            
            infile = (argv[0]==string{"-"} ? NULL : argv[0]);
        }
        
        else if (argv[0]==string{"-der"}) {
            use_pem = false;
        }
        
        else { break; }
    }
    
    
    if (argv[0]) { throw runtime_error("checkend error: unknown option(s)"); }
    
    bool valid = checkend(infile, seconds, use_pem);
    cout<<"Certificate will"<<( valid ? " not " : " ")<<"expire"<<endl;
    
    return (valid ? 0 : 1);
}


void eckey(const char * argv[]);
void eckey(const char * argv[]) {

}


void selfsigned(const char * argv[]);
void selfsigned(const char * argv[])
{
    //TODO
}    


void usage();
void usage()
{
    //TODO
}


int main(int argc, const char * argv[]) {
    try {
        if (!argv[1]) { throw runtime_error("error: no argument"); }

        else if (argv[1]==string{"checkend"}) { return checkend(argv+2); }

        else if (argv[1]==string{"eckey"}) { eckey(argv+2); }

        else if (argv[1]==string{"rsakey"}) { selfsigned(argv+2); }

        else if (argv[1]==string{"selfsigned"}) { selfsigned(argv+2); }

        else { throw runtime_error("error: argument not recognized"); }
        
    } catch (const std::exception & e)  {

        usage();

        cerr<<e.what()<<endl;
        return 1;
    }

    return 0;
}
