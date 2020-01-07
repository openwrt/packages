
// #define openwrt

#include <chrono>

#include <cstdio>
#include <iostream>
#include <string>
// #include <regex>
#include "regex-pcre.hpp"
#include "nginx-utils-common.hpp"
#include "px5g-openssl.hpp"
#ifdef openwrt
#include "ubus-cxx.hpp"
#endif

using namespace std;


static const auto PROGRAM_NAME = string{"/usr/bin/nginx-utils"};
static const auto CONF_DIR = string{"/etc/nginx/conf.d/"};
static const auto LAN_NAME = string{"_lan"};
static const auto LAN_LISTEN = string{"/var/lib/nginx/lan.listen"};
static const auto LAN_SSL_LISTEN = string{"/var/lib/nginx/lan_ssl.listen"};
static const auto ADD_SSL_FCT = string{"add_ssl"};
static const auto NGX_SSL_SESSION_TIMEOUT_PARAM = string{"64m;"};
static const auto NGX_SSL_SESSION_CACHE_PARAM =
    [](const string name){ return "'shared:SSL:32k';"; };

class Line {
public:
    typedef const string (*fn)(const string & parameter, const string & begin);
    Line(fn str, const string rgx) : STR{str}, RGX{rgx} {}
    fn STR;
    const regex RGX;
};

// For a compile time regex lib, this must be fixed, use one of these options:
// * Hand craft or macro concat them (loosing more or less flexibility).
// * Use Macro concatenation of __VA_ARGS__ with the help of:
//   https://p99.gforge.inria.fr/p99-html/group__preprocessor__for.html
// * Use constexpr---not available for strings or char * for now---look at lib.
#define _LINE_(name, code) \
    Line name{ \
        [](const string & parameter, const string & begin) \
        -> const string { \
            const auto arg = \
            [parameter](const string & str = "", const string & lim="") \
            -> const string { \
                return (str=="" ? "'"+parameter+"'" : lim+str+lim); \
            }; \
            const string space = " "; \
            const string end = ";"; \
            return code; \
        }, \
        []() -> const string { \
            const string begin = R"([{;](\s*))"; \
            const string space = R"(\s+)"; \
            const string end = R"(\s*;)"; \
            const auto arg = \
            [](const string & str = "", const string & lim="\\s") \
            -> const string { \
                if (str=="") { \
                    return R"(((?:(?:"[^"]*")|(?:[^'")"+lim+"][^"+lim+"]*)|(?:'[^']*'))+)";\
                } \
                string ret = ""; \
                for (char c : str) { \
                    switch(c) { \
                        case '^': ret += '\\'; [[fallthrough]]; \
                        case '_': [[fallthrough]]; \
                        case '-': ret += c; \
                        break; \
                        default: \
                            if (isalpha(c) || isdigit(c)) { ret += c; } \
                            else { ret += (string)"["+c+"]"; } \
                    } \
                } \
                return "(?:"+ret+"|'"+ret+"'"+"|\""+ret+"\""+")"; \
            }; \
            return code; \
        }() \
    };

// arg(name, delimiter="") escapes arguments, arg("", delimiter="\n") captures:
_LINE_(CRON_CMD,
       space+arg(PROGRAM_NAME)+space+arg(ADD_SSL_FCT, "'")+space+arg()+'\n');
_LINE_(NGX_SERVER_NAME,
       begin + arg("server_name") + space + arg("", ";") +end);
_LINE_(NGX_INCLUDE_LAN_LISTEN,
       begin + arg("include") + space + arg(LAN_LISTEN, "'") +end);
_LINE_(NGX_INCLUDE_LAN_LISTEN_DEFAULT,
       begin + arg("include") + space + arg(LAN_LISTEN+".default", "'") +end);
_LINE_(NGX_INCLUDE_LAN_SSL_LISTEN,
       begin + arg("include") + space + arg(LAN_SSL_LISTEN, "'") +end);
_LINE_(NGX_INCLUDE_LAN_SSL_LISTEN_DEFAULT,
       begin+ arg("include") +space+ arg(LAN_SSL_LISTEN+".default", "'") +end);
_LINE_(NGX_SSL_CRT,
       begin+ arg("ssl_certificate") +space+ arg("", ";") +end);
_LINE_(NGX_SSL_KEY,
       begin+ arg("ssl_certificate_key") + space + arg("", ";") +end);
_LINE_(NGX_SSL_SESSION_CACHE, begin+ arg("ssl_session_cache") +space);
_LINE_(NGX_SSL_SESSION_TIMEOUT, begin+ arg("ssl_session_timeout") +space);

#undef _LINE_


string get_if_missed(const string & conf, const Line & LINE, const string & val,
                   const string & indent="\n    ");
string get_if_missed(const string & conf, const Line & LINE, const string & val,
                   const string & indent)
{
    if (val=="") {
        return regex_search(conf, LINE.RGX) ? "" : LINE.STR(val, indent);
    }

    smatch match; // assuming last capture has the value!

    for (auto pos = conf.begin();
         regex_search(pos, conf.end(), match, LINE.RGX);
         pos += match.position(0) + match.length(0))
    {
        const string value = match.str(match.size() - 1);

        if (value==val || value=="'"+val+"'" || value=='"'+val+'"') {
            return "";
        }
    }

    return LINE.STR(val, indent);
}


void add_ssl_directives_to(const string & name, const bool isdefault);
void add_ssl_directives_to(const string & name, const bool isdefault)
{
    const string prefix = CONF_DIR + name;

    string conf = read_file(prefix+".conf");

    const string & const_conf = conf; // iteration needs const string.
    smatch match; // captures str(1)=indentation spaces, str(2)=server name
    for (auto pos = const_conf.begin();
        regex_search(pos, const_conf.end(), match, NGX_SERVER_NAME.RGX);
        pos += match.position(0) + match.length(0))
    {
        if (match.str(2).find(name) == string::npos) { continue; }

        const string indent = match.str(1);

        string adds = isdefault ?
            get_if_missed(conf, NGX_INCLUDE_LAN_SSL_LISTEN_DEFAULT,"",indent) :
            get_if_missed(conf, NGX_INCLUDE_LAN_SSL_LISTEN, "", indent);

        adds += get_if_missed(conf, NGX_SSL_CRT, prefix+".crt", indent);

        adds += get_if_missed(conf, NGX_SSL_KEY, prefix+".key", indent);

        {
            string tmp;

            tmp = get_if_missed(conf, NGX_SSL_SESSION_CACHE, "", indent);
            if (tmp != "") { adds += tmp + NGX_SSL_SESSION_CACHE_PARAM(name); }

            tmp = get_if_missed(conf, NGX_SSL_SESSION_TIMEOUT, "", indent);
            if (tmp != "") { adds += tmp + NGX_SSL_SESSION_TIMEOUT_PARAM; }
        }

        if (adds.length() > 0) {
            pos += match.position(0) + match.length(0);

            conf = string(const_conf.begin(), pos) + adds + string(pos, const_conf.end());

            conf = isdefault ?
                regex_replace(conf, NGX_INCLUDE_LAN_LISTEN_DEFAULT.RGX,"") :
                regex_replace(conf, NGX_INCLUDE_LAN_LISTEN.RGX, "");

            write_file(prefix+".conf", conf);

            cout<<"Added SSL directives to "<<prefix<<".conf: "<<adds<<endl;
        }

        return;
    }

    cout<<"Cannot add SSL directives to "<<prefix<<".conf, missing:";
    cout<<NGX_SERVER_NAME.STR(name, "\n    ")<<endl;
}


void use_cron_to_recreate_certificate(const string & name);
void use_cron_to_recreate_certificate(const string & name)
{
#ifdef openwrt
    static const char * filename = "/etc/crontabs/root";

    string conf{};
    try { conf = read_file(filename); }
    catch (const ifstream::failure &) { /* it is ok if not found, create. */ }

    const string add = get_if_missed(conf, CRON_CMD, name);

    if (add.length() > 0) {
        auto service = ubus::call("service", "list", 1000).filter("cron");

        if (!service) {
            cout<<"Cron unavailable to re-create the ssl certificate for '";
            cout<<name<<"'."<<endl;
        } else { // active with or without instances:

            const auto cron_interval = "3 3 12 12 *"; // once a year.
            write_file(filename, cron_interval+add, ios::app);

            call("/etc/init.d/cron", "reload");

            cout<<"Rebuild the ssl certificate for '";
            cout<<name<<"' annually with cron."<<endl;
        }
    }
#else
cout<<"Skip checking cron for: ... "<<get_if_missed("", CRON_CMD, name)<<endl;
#endif
}


void create_lan_listen();
void create_lan_listen()
{
#ifdef openwrt
    string listen = "# This file is re-created if Nginx starts or"
                    " a LAN address changes.\n";
    string listen_default = listen;
    string ssl_listen = listen;
    string ssl_listen_default = listen;

    auto add_listen = [&listen, &listen_default,
                       &ssl_listen, &ssl_listen_default]
        (const string & prefix, string ip, const string & suffix) -> void
    {
        if (ip == "") { return; }
        ip = prefix + ip + suffix;
        listen += "\tlisten " + ip + ":80;\n";
        listen_default += "\tlisten " + ip + ":80 default_server;\n";
        ssl_listen += "\tlisten " + ip + ":443 ssl;\n";
        ssl_listen_default += "\tlisten " + ip + ":443 ssl default_server;\n";
    };

    add_listen("", "127.0.0.1", "");
    add_listen("[", "::1", "]");

    auto lan_status = ubus::call("network.interface.lan", "status");

    for (auto ip : lan_status.filter("ipv4-address", "", "address")) {
        add_listen("",  blobmsg_get_string(ip), "");
    }

    for (auto ip : lan_status.filter("ipv6-address", "", "address")) {
        add_listen("[", blobmsg_get_string(ip), "]");
    }

    write_file(LAN_LISTEN, listen);
    write_file(LAN_LISTEN+".default", listen_default);
    write_file(LAN_SSL_LISTEN, ssl_listen);
    write_file(LAN_SSL_LISTEN+".default", ssl_listen_default);
#endif
}


void create_ssl_certificate(const string & crtpath, const string & keypath,
                            const unsigned long days=792);
void create_ssl_certificate(const string & crtpath, const string & keypath,
                            const unsigned long days)
{
    const int n = 4;
    char nonce[2*n+1];
    try {
        ifstream urandom{"/dev/urandom"};
        for (int i=0; i<n && urandom.good(); ++i) {
            auto byte = (unsigned)urandom.get();
            const char hex[17] = "0123456789ABCDEF";
            nonce[2*i] = hex[byte >> 4];
            nonce[2*i+1] = hex[byte & 0x0f];
        }
        urandom.close();
    } catch (...) { /* not that problematic, use current content of nonce. */ }
    nonce[2*n] = '\0';

    const auto tmpcrtpath = crtpath + ".new-" + nonce;
    const auto tmpkeypath = keypath + ".new-" + nonce;

    try {
        auto pkey = gen_eckey(NID_secp384r1);

        write_key(pkey, tmpkeypath.c_str());

        string subject {"/C=ZZ/ST=Somewhere/L=None/CN=OpenWrt/O=OpenWrt"};
        subject += nonce;

        selfsigned(pkey, subject.c_str(), days, tmpcrtpath.c_str());

        if (!checkend(tmpcrtpath.c_str(), days*24*60*60 - 42)) {
            throw runtime_error("bug: created certificate is not valid!!");
        }

    } catch (...) {
        cerr<<"error: cannot create selfsigned certificate, ";
        cerr<<"removing temporary files ..."<<endl;

        if (remove(tmpcrtpath.c_str())!=0) {
            auto errmsg = "error: cannot remove "+tmpcrtpath;
            perror(errmsg.c_str());
        }

        if (remove(tmpkeypath.c_str())!=0) {
            auto errmsg = "error: cannot remove "+tmpkeypath;
            perror(errmsg.c_str());
        }

        throw;
    }

    if ( rename(tmpcrtpath.c_str(), crtpath.c_str())!=0 ||
         rename(tmpkeypath.c_str(), keypath.c_str())!=0 )
    {
        auto errmsg = "error: cannot move "+tmpcrtpath+" to "+crtpath;
        errmsg = ", or "+tmpkeypath+" to "+keypath;
        perror(errmsg.c_str());
    }

}


void add_ssl_if_needed(const string & name);
void add_ssl_if_needed(const string & name)
{
    try { add_ssl_directives_to(name, name==LAN_NAME); }
    catch (...) {
        cout<<"Cannot add SSL directives to "<<name<<".conf"<<endl;
        throw;
    }

    const auto crtpath = CONF_DIR + name + ".crt";
    const auto keypath = CONF_DIR + name + ".key";
    const auto remaining_seconds = (365 + 32)*24*60*60;
    const auto validity_days = 3*(365 + 31);

    bool is_valid = true;

    if (access(keypath.c_str(), F_OK) == -1) { is_valid = false; }

    else if (access(crtpath.c_str(), F_OK) == -1) { is_valid = false; }

    else {
        try {
            if (!checkend(crtpath.c_str(), remaining_seconds)) {
                is_valid = false;
            }
        }
        catch (...) { // something went wrong, maybe it is in DER format:
            try {
                if (!checkend(crtpath.c_str(), remaining_seconds, false)) {
                    is_valid = false;
                }
            }
            catch (...) { // it has neither DER nor PEM format, rebuild.
                is_valid = false;
            }
        }
    }

    if (!is_valid) { create_ssl_certificate(crtpath, keypath, validity_days); }

    try { use_cron_to_recreate_certificate(name); }
    catch (...) {
        cout<<"Cannot use cron to rebuild the certificate for "<<name<<endl;
    }
}


// void time_it(chrono::time_point<chrono::steady_clock> begin);
// void time_it(chrono::time_point<chrono::steady_clock> begin)
// {
//     auto end = chrono::steady_clock::now();
//     cout << "Time difference = " <<
//     chrono::duration_cast<chrono::milliseconds>(end - begin).count()
//     << " ms" << endl;
// }


/*#include <sys/wait.h>
#define THREAD(name, call) pid_t name = fork(); \
    switch(name) { \
        case 0: call(); _exit(0); \
        case -1: cout<<"error forking "<<name<<", run in main process"<<endl; \
            call(); \
    }
#define JOIN(name) if (name>0) { \
        int status; \
        if(waitpid(name, &status, 0) < 0) cout<<"error waiting "<<name<<endl; \
    }*/



// #define THREAD(name, call) call()
// #define JOIN(name) (void)0

#include <thread>
#define THREAD(name, call) thread name(call)
#define JOIN(name) name.join()


void init_lan();
void init_lan()
{
    THREAD(ubus, create_lan_listen);

    try { add_ssl_if_needed(LAN_NAME); }
    catch (...) {
        JOIN(ubus);
        throw;
    }

    JOIN(ubus);
}

void get_env(const string & name=LAN_NAME);
void get_env(const string & name)
{
    const string prefix = CONF_DIR + name;
    cout<<"NGINX_CONF="<<'"'<<"/etc/nginx/nginx.conf"<<'"'<<endl;
    cout<<"CONF_DIR="<<'"'<<CONF_DIR<<'"'<<endl;
    cout<<"LAN_NAME="<<'"'<<LAN_NAME<<'"'<<endl;
    cout<<"LAN_LISTEN="<<'"'<<LAN_LISTEN<<'"'<<endl;
    cout<<"LAN_SSL_LISTEN="<<'"'<<LAN_SSL_LISTEN<<'"'<<endl;
    cout<<"ADD_SSL_FCT="<<'"'<<ADD_SSL_FCT<<'"'<<endl;
    cout<<"NGX_SSL_CRT="<<'"'<<NGX_SSL_CRT.STR(prefix+".crt", "")<<'"'<<endl;
    cout<<"NGX_SSL_KEY="<<'"'<<NGX_SSL_KEY.STR(prefix+".key", "")<<'"'<<endl;
    cout<<"NGX_SSL_SESSION_CACHE="<<'"'<<
            NGX_SSL_SESSION_CACHE.STR("", "")<<
            NGX_SSL_SESSION_CACHE_PARAM(name)<<'"'<<endl;
    cout<<"NGX_SSL_SESSION_TIMEOUT="<<'"'<<
            NGX_SSL_SESSION_TIMEOUT.STR("", "")<<
            NGX_SSL_SESSION_TIMEOUT_PARAM<<'"'<<endl;
}


int main(int argc, char * argv[]) {
#ifdef openwrt
cout<<"TODO: remove timing and openwrt macro!"<<endl;
#endif

    //TODO more?
    string cmds[][2] = {
        { "init_lan", ""},
        { ADD_SSL_FCT, " server_name" },
        { "get_env", " [name]"}
    };

    if (argc==2 && argv[1]==cmds[0][0]) { init_lan(); }

    else if (argc==3 && argv[1]==cmds[1][0]) { add_ssl_if_needed(argv[2]); }

    else if (argc==2 && argv[1]==cmds[2][0]) { get_env(); }

    else if (argc==3 && argv[1]==cmds[2][0]) { get_env(argv[2]); }

    else {
        auto usage = string{"usage: "} + argv[0] + " [";

        for (auto cmd : cmds) { usage += cmd[0] + cmd[1] + "|"; }

        usage[usage.size()-1] = ']';
        cerr<<usage<<endl;
        return 2;
    }

    return 0;
}

//TODO: _lan.conf # as seen by: ubus call network.interface.lan status | grep '"address"'

