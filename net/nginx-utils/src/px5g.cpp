
#include <fcntl.h>

# include <unistd.h>
# include <stdlib.h>
# include <string.h>
#include <string>
// #include <stdexcept>
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


int checkend(const char * argv[]);
int checkend(const char * argv[])
{
    bool use_pem = true;
    const char * infile = NULL;
    time_t seconds = 0;

    for (; argv[0]; ++argv) {
        if (argv[0]==string{"-der"}) {
            use_pem = false;
        } else if (argv[0]==string{"-in"}) {
            ++argv;

            if (!argv[0]) {
                throw runtime_error("checkend error: -in misses filename");
            }

            if (infile) {
                if (argv[0]==infile) {
                    cerr<<"checkend warning: repeated same -in file"<<endl;
                } else {
                    throw runtime_error
                                    ("checkend error: more than one -in file");
                }
            }

            infile = (argv[0]==string{"-"} ? NULL : argv[0]);
        }

        else if (argv[0][0]=='-') {
            cerr<<"checkend warning: skip unknown option "<<argv[0]<<endl;
        } else { // main option:
            intmax_t num = 0;

            try {
                num = parse_int(argv[0]);
            } catch(...) {
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

    bool valid = checkend(infile, seconds, use_pem);
    cout<<"Certificate will"<<( valid ? " not " : " ")<<"expire"<<endl;

    return (valid ? 0 : 1);
}



void eckey(const char * argv[]);
void eckey(const char * argv[])
{
    bool use_pem = true;
    const char * outfile = NULL;
    int curve = NID_X9_62_prime256v1;
    bool has_main_option = false;

    for (; argv[0]; ++argv) {
        if (argv[0]==string{"-der"}) {
            use_pem = false;
        } else if (argv[0]==string{"-out"}) {
            ++argv;

            if (!argv[0]) {
                throw runtime_error("eckey error: -out misses filename");
            }

            if (outfile) {
                if (argv[0]==outfile) {
                    cerr<<"eckey warning: repeated same -out file"<<endl;
                } else {
                    throw runtime_error("eckey error: more than one -out file");
                }
            }

            outfile = (argv[0]==string{"-"} ? NULL : argv[0]);
        }

        else if (argv[0][0]=='-') {
            cerr<<"eckey warning: skip unknown option "<<argv[0]<<endl;
        } else { //main option:

            if (has_main_option) {
                throw runtime_error("eckey error: more than one main option");
            } // else:
            has_main_option = true;

            string name = argv[0];
            if (name=="P-256" || name=="secp256r1") { curve = NID_X9_62_prime256v1; }
            else if (name=="secp192r1") { curve = NID_X9_62_prime192v1; }
            else if (name=="P-384") { curve = NID_secp384r1; }
            else if (name=="P-521") { curve = NID_secp521r1; }
            else { curve = OBJ_sn2nid(name.c_str()); }

            // not: if (curve == 0) { curve = EC_curve_nist2nid(name.c_str()); }
        }
    }

    auto eckey = gen_eckey(curve);

    try {
        write_key(outfile, eckey, use_pem);
    } catch(...) {
        EC_KEY_free(eckey);
        throw;
    }

    EC_KEY_free(eckey);
}


void rsakey(const char * argv[]);
void rsakey(const char * argv[])
{
    bool use_pem = true;
    const char * outfile = NULL;
    unsigned long exponent = 65537;
    int keysize = 512;
    bool has_main_option = false;

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

            if (outfile) {
                if (argv[0]==outfile) {
                    cerr<<"rsakey warning: repeated same -out file"<<endl;
                } else {
                    throw runtime_error("rsakey error: more than one -out file");
                }
            }

            outfile = (argv[0]==string{"-"} ? NULL : argv[0]);
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
            } catch(...) {
                auto msg = string{"rsakey error: invalid keysize "} + argv[0];
                throw_with_nested(runtime_error(msg.c_str()));
            }
        }
    }

    auto rsakey = gen_rsakey(keysize, exponent);

    try {
        write_key(outfile, rsakey, use_pem);
    } catch(...) {
        RSA_free(rsakey);
        throw;
    }

    RSA_free(rsakey);
}


void selfsigned(const char * argv[]);
void selfsigned(const char * argv[])
{
    //TODO
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
