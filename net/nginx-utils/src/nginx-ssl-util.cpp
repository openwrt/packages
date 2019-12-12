
#define openwrt

#include <chrono>

#include <iostream>
#include <string>
// #include <regex>
#include "regex-pcre.hpp"
#include "ubus.hpp"
#include "common.hpp"


#include "common.hpp"

using namespace std;

static const string LAN_LISTEN = "/var/lib/nginx/lan.listen";
static const string LAN_SSL_LISTEN = "/var/lib/nginx/lan_ssl.listen";
static const string ADD_SSL_FCT = "add_ssl";
// const string NAME="_lan"
// const string PREFIX="/etc/nginx/conf.d/_lan"

#ifdef openwrt
static const string CONF_DIR = "/etc/nginx/conf.d/";
#else
static const string CONF_DIR = "";
#endif

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
        [](const string & parameter = "$", const string & begin = "\n    ") \
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
            const string begin = R"((\n\s*))"; \
            const string space = R"(\s+)"; \
            const string end = R"(\s*;)"; \
            const auto arg = \
            [](const string & str = "", const string & lim="\n") \
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
       space+arg("/etc/init.d/nginx")+space+arg(ADD_SSL_FCT, "'")+space+arg());
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
_LINE_(NGX_SSL_SESSION_CACHE,
      begin+ arg("ssl_session_cache") +space+ arg("shared:SSL:32k", "'") +end);
_LINE_(NGX_SSL_SESSION_TIMEOUT,
      begin+ arg("ssl_session_timeout") +space+ arg("64m", "'") +end);
#undef _LINE_


string get_if_missed(const string & conf, const Line & LINE, const string & val,
                   const string & indent="\n    ");
string get_if_missed(const string & conf, const Line & LINE, const string & val,
                   const string & indent)
{
    if (val=="") {
        return regex_search(conf, LINE.RGX) ? "" : LINE.STR(val, indent);
    }
    smatch match;
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
    const string conf = read_file(prefix+".conf");
    smatch match;
    for (auto pos = conf.begin();
         regex_search(conf.begin(), conf.end(), match, NGX_SERVER_NAME.RGX);
         pos += match.position(0) + match.length(0))
    {
        if (match.str(2).find(name) == string::npos) { continue; }
        const string indent = match.str(1);
        string adds = "";
        adds += isdefault ?
            get_if_missed(conf, NGX_INCLUDE_LAN_SSL_LISTEN_DEFAULT,"",indent) :
            get_if_missed(conf, NGX_INCLUDE_LAN_SSL_LISTEN, "", indent);
        adds += get_if_missed(conf, NGX_SSL_CRT, prefix+".crt", indent);
        adds += get_if_missed(conf, NGX_SSL_KEY, prefix+".key", indent);
        adds += get_if_missed(conf, NGX_SSL_SESSION_CACHE, "", indent);
        adds += get_if_missed(conf, NGX_SSL_SESSION_TIMEOUT, "", indent);
        if (adds.length() > 0) {
            pos += match.position(0) + match.length(0);
            string conf2; // conf is const for iteration.
            conf2 = string(conf.begin(), pos) + adds + string(pos, conf.end());
            conf2 = isdefault ?
                   regex_replace(conf2, NGX_INCLUDE_LAN_LISTEN_DEFAULT.RGX,"") :
                   regex_replace(conf2, NGX_INCLUDE_LAN_LISTEN.RGX, "");
            write_file(prefix+".conf", conf2);
            cout<<"Added SSL directives to "<<prefix<<".conf:"<<adds<<endl;
        }
        return ;
    }
    cout<<"Cannot add SSL directives to "<<prefix<<".conf, missing:";
    cout<<NGX_SERVER_NAME.STR(name, "\n    ")<<endl;
}


void try_using_cron_to_recreate_certificate(const string & name);
void try_using_cron_to_recreate_certificate(const string & name)
{
#ifdef openwrt
    static const char * filename = "/etc/crontabs/root";
    string conf = read_file(filename);
    const string CRON_CHECK = "3 3 12 12 *";
    const string add = get_if_missed(conf, CRON_CMD, name);
    if (add.length() > 0) {
        bool active = false;
        for (auto x : ubus::call("service", "list").filter("cron")) {
            active = (x!=NULL);
        }
        if (active) {
            cout<<"Cron unavailable to re-create the ssl certificate for '";
            cout<<name<<"'."<<endl;
        } else {
            write_file(filename, CRON_CHECK+add, ios::app);
            call("/etc/init.d/cron", "reload");
            cout<<"Rebuild the ssl certificate for '";
            cout<<name<<"' annually with cron."<<endl;
        }
    }
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
        add_listen("",  (char *)(ip), "");
    }
    for (auto ip : lan_status.filter("ipv6-address", "", "address")) {
        add_listen("[", (char *)(ip), "]");
    }

    write_file(LAN_LISTEN, listen);
    write_file(LAN_LISTEN+".default", listen_default);
    write_file(LAN_SSL_LISTEN, ssl_listen);
    write_file(LAN_SSL_LISTEN+".default", ssl_listen_default);
#endif
}


void time_it(chrono::time_point<chrono::steady_clock> begin);
void time_it(chrono::time_point<chrono::steady_clock> begin)
{
    auto end = chrono::steady_clock::now();
    cout << "Time difference = " <<
    chrono::duration_cast<chrono::milliseconds>(end - begin).count()
    << " ms" << endl;
}


int main(int argc, char * argv[]) {
    auto begin = chrono::steady_clock::now();
#ifdef openwrt
    cout<<"here"<<endl;
#endif


    if (argc != 2) {
        cout<<"syntax: "<<argv[0]<<" server_name"<<endl;
        return 2;
    }
    const string name = argv[1];
    time_it(begin);

    create_lan_listen();
    time_it(begin);

    add_ssl_directives_to(name, name=="_lan");
    time_it(begin);

    try_using_cron_to_recreate_certificate(name);
    time_it(begin);

    return 0;
}

//TODO: _lan.conf # as seen by: ubus call network.interface.lan status | grep '"address"'

