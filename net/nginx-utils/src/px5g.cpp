
#include <fcntl.h>
#include <unistd.h>
#include <string>
#include <iostream>
using namespace std;
#include "px5g-openssl.hpp"


inline int parse_int(string arg);
inline int parse_int(string arg)
{
    size_t pos;
    int ret = stoi(arg, &pos);
    if (pos < arg.size()) {
        throw runtime_error("number has trailing char");
    }
    return ret;
}

inline auto parse_curve(string name) {
    if (name=="P-256" || name=="secp256r1") { return NID_X9_62_prime256v1; }
    else if (name=="secp192r1") { return NID_X9_62_prime192v1; }
    else if (name=="P-384") { return NID_secp384r1; }
    else if (name=="P-521") { return NID_secp521r1; }
    else { return OBJ_sn2nid(name.c_str()); }
    // not: if (curve == 0) { curve = EC_curve_nist2nid(name.c_str()); }
}

int checkend(const char * argv[]);
int checkend(const char * argv[])
{
    bool use_pem = true;
    const char * crtpath = NULL;
    time_t seconds = 0;

    for (; argv[0]; ++argv) {
        if (argv[0]==string{"-der"}) {
            use_pem = false;
        } else if (argv[0]==string{"-in"}) {
            ++argv;

            if (!argv[0]) {
                throw runtime_error("checkend error: -in misses filename");
            }

            if (crtpath) {
                if (argv[0]==crtpath) {
                    cerr<<"checkend warning: repeated same -in file"<<endl;
                } else {
                    throw runtime_error
                                    ("checkend error: more than one -in file");
                }
            }

            crtpath = (argv[0]==string{"-"} ? NULL : argv[0]);
        }

        else if (argv[0][0]=='-') {
            cerr<<"checkend warning: skip unknown option "<<argv[0]<<endl;
        } else { // main option:
            intmax_t num = 0;

            try {
                num = parse_int(argv[0]);
            } catch (...) {
                auto msg = string{"checkend error: invalid time "} + argv[0];
                throw_with_nested(runtime_error(msg.c_str()));
            }

            seconds = reinterpret_cast<time_t>(num);

            if (num!=(intmax_t)seconds) {
                auto msg = string{"checkend error: time too big "} + argv[0];
                throw(runtime_error(msg.c_str()));
            }
        }
    }

    bool valid = checkend(crtpath, seconds, use_pem);
    cout<<"Certificate will"<<( valid ? " not " : " ")<<"expire"<<endl;

    return (valid ? 0 : 1);
}



void eckey(const char * argv[]);
void eckey(const char * argv[])
{
    bool has_main_option = false;
    bool use_pem = true;
    const char * keypath = NULL;
    int curve = NID_X9_62_prime256v1;

    for (; argv[0]; ++argv) {
        if (argv[0]==string{"-der"}) {
            use_pem = false;
        } else if (argv[0]==string{"-out"}) {
            ++argv;

            if (!argv[0]) {
                throw runtime_error("eckey error: -out misses filename");
            }

            if (keypath) {
                if (argv[0]==keypath) {
                    cerr<<"eckey warning: repeated same -out file"<<endl;
                } else {
                    throw runtime_error("eckey error: more than one -out file");
                }
            }

            keypath = (argv[0]==string{"-"} ? NULL : argv[0]);
        }

        else if (argv[0][0]=='-') {
            cerr<<"eckey warning: skip unknown option "<<argv[0]<<endl;
        } else { //main option:

            if (has_main_option) {
                throw runtime_error("eckey error: more than one main option");
            } // else:
            has_main_option = true;

            curve = parse_curve(argv[0]);
        }
    }

    write_key(gen_eckey(curve), keypath, use_pem);
}


void rsakey(const char * argv[]);
void rsakey(const char * argv[])
{
    bool has_main_option = false;
    bool use_pem = true;
    const char * keypath = NULL;
    unsigned long exponent = 65537;
    int keysize = 512;

    for (; argv[0]; ++argv) {
        if (argv[0]==string{"-der"}) {
            use_pem = false;
        } else if (argv[0]==string{"-3"}) {
            exponent = 3;
        } else if (argv[0]==string{"-out"}) {
            ++argv;

            if (!argv[0]) {
                throw runtime_error("rsakey error: -out misses filename");
            }

            if (keypath) {
                if (argv[0]==keypath) {
                    cerr<<"rsakey warning: repeated same -out file"<<endl;
                } else {
                    throw runtime_error("rsakey error: more than one -out file");
                }
            }

            keypath = (argv[0]==string{"-"} ? NULL : argv[0]);
        }

        else if (argv[0][0]=='-') {
            cerr<<"rsakey warning: skip unknown option "<<argv[0]<<endl;
        } else { //main option:

            if (has_main_option) {
                throw runtime_error("rsakey error: more than one main option");
            } // else:
            has_main_option = true;

            try {
                keysize = parse_int(argv[0]);
            } catch (...) {
                string errmsg{"rsakey error: invalid keysize "};
                errmsg += argv[0];
                throw_with_nested(runtime_error(errmsg.c_str()));
            }
        }
    }

    write_key(gen_rsakey(keysize, exponent), keypath, use_pem);
}


void selfsigned(const char * argv[]);
void selfsigned(const char * argv[])
{
    bool use_pem = true;
    unsigned long days = 30;
    const char * keypath = NULL;
    const char * crtpath = NULL;
    const char * subject = NULL; 
    
    bool use_rsa = true;
    int keysize = 512;
    unsigned long exponent = 65537;
    
    int curve = NID_X9_62_prime256v1;
    
    for (; argv[0]; ++argv) {
        if (argv[0]==string{"-der"}) {
            use_pem = false;
        } else if (argv[0]==string{"-days"}) {
            try {
                days = parse_int(argv[0]);
            } catch (...) {
                string errmsg{"selfsigned error: invalid number for -days "};
                errmsg += &argv[0][4];
                throw_with_nested(runtime_error(errmsg.c_str()));
            }
        }
        
        else if (argv[0]==string{"-newkey"}) {
            ++argv;

            if (!argv[0]) {
                throw runtime_error("selfsigned error: -newkey misses value");
            }
            
            if (argv[0]==string{"ec"}) {
                use_rsa = false;
            } else if (string(argv[0], 4)=="rsa:") {
                use_rsa = true;
                try {
                    keysize = parse_int(&argv[0][4]);
                } catch (...) {
                    string errmsg{"selfsigned error: invalid rsa keysize "};
                    errmsg += &argv[0][4];
                    throw_with_nested(runtime_error(errmsg.c_str()));
                }
            } else {
                throw runtime_error("selfsigned error: invalid algorithm");
            }
        }
        
        else if (argv[0]==string{"-pkeyopt"}) {
            ++argv;

            if (!argv[0]) {
                throw runtime_error("selfsigned error: -pkeyopt misses value");
            }

            if (string(argv[0], 18)!="ec_paramgen_curve:") {
                throw runtime_error("selfsigned error: -pkeyopt invalid");
            }

            curve = parse_curve(&argv[0][18]);
        }
        
        else if (argv[0]==string{"-keyout"}) {
            ++argv;

            if (!argv[0]) {
                throw runtime_error("selfsigned error: -keyout misses path");
            }

            if (keypath) {
                if (argv[0]==keypath) {
                    cerr<<"selfsigned warning: repeated -keyout file"<<endl;
                } else {
                    throw runtime_error
                        ("selfsigned error: more than one -keyout file");
                }
            }

            keypath = (argv[0]==string{"-"} ? NULL : argv[0]);
        }
        
        else if (argv[0]==string{"-out"}) {
            ++argv;

            if (!argv[0]) {
                throw runtime_error("selfsigned error: -out misses filename");
            }

            if (crtpath) {
                if (argv[0]==crtpath) {
                    cerr<<"selfsigned warning: repeated same -out file"<<endl;
                } else {
                    throw runtime_error
                        ("selfsigned error: more than one -out file");
                }
            }

            crtpath = (argv[0]==string{"-"} ? NULL : argv[0]);
        }
        
        else if (argv[0]==string{"-subj"}) {
            ++argv;

            if (!argv[0]) {
                throw runtime_error("selfsigned error: -subj misses value");
            }

            if (subject) {
                if (argv[0]==subject) {
                    cerr<<"selfsigned warning: repeated same -subj"<<endl;
                } else {
                    throw runtime_error
                        ("selfsigned error: more than one -subj value");
                }
            }

            subject = argv[0];
        } 
        
        else { 
            cerr<<"selfsigned warning: skip unknown option "<<argv[0]<<endl;
        }
    }
    
    auto pkey = use_rsa ? gen_rsakey(keysize, exponent) : gen_eckey(curve);

    selfsigned(pkey, subject, days, crtpath, use_pem);
    
    if (keypath) { write_key(pkey, keypath, use_pem); }
}


int main(int argc, const char * argv[]) {
    try {
        if (!argv[1]) { throw runtime_error("error: no argument"); }

        else if (argv[1]==string{"checkend"}) { return checkend(argv+2); }

        else if (argv[1]==string{"eckey"}) { eckey(argv+2); }

        else if (argv[1]==string{"rsakey"}) { rsakey(argv+2); }

        else if (argv[1]==string{"selfsigned"}) { selfsigned(argv+2); }

        else { throw runtime_error("error: argument not recognized"); }

    } catch (const exception & e)  {
        auto print_nested =
            [](auto && self, const exception & outer, int depth=0) -> void
        {
            cerr<<string(depth, '\t')<<outer.what()<<endl;
            try { rethrow_if_nested(outer); }
            catch (const exception & inner) { self(self, inner, depth+1); }
        };

        print_nested(print_nested, e);

        // TODO usage

        return 1;
    }

    return 0;
}
