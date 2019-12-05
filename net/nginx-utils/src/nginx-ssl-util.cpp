#include <iostream>
#include <string>
#include <fstream>
#include <streambuf>
#include <unistd.h>
#include <sys/wait.h>
#include <chrono>

#define openwrt

#ifdef openwrt
#ifdef __cplusplus
extern "C" {
#endif
#include <libubus.h>
#ifdef __cplusplus
}
#endif
#endif


// implement *some* <regex> functions using pcre for performance:

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
    ~smatch() { if (vec) { delete [] vec; } }
    
    std::string suffix() {
        return str.substr(vec[1]);
    }
    std::string prefix() {
        return str.substr(0, vec[0]);
    }
    
    std::string operator[](int i) const  {
        if (i<0 || i>=n) { return ""; }
        int x = vec[2*i];
        if (x<0) { return ""; }
        int len = vec[2*i+1] - x;
        return str.substr(x, len);
    }
    
    friend bool regex_search(const std::string &, smatch &, const regex &);
private: 
    const regex * rgx;
    std::string str;
    int pos = 0;
    int * vec = NULL;
    int n = 0;
};

bool regex_search(const std::string & subj, smatch & match, const regex & rgx);
bool regex_search(const std::string & subj, smatch & match, const regex & rgx) {
    if (rgx()==NULL) {
        
    } else {
        if (match.str != subj || match.rgx != &rgx) {
            match.pos = 0;
            match.str = subj;
            match.rgx = &rgx;
        }
        if (match.vec) { delete [] match.vec; }
        size_t sz = 0;
        pcre_fullinfo(rgx(), NULL, PCRE_INFO_CAPTURECOUNT, &sz);
        sz = 3*(sz + 1);
        match.vec = new int[sz];
        match.n = pcre_exec(rgx(), NULL, subj.c_str(), subj.length(), 
                            match.pos, 0, match.vec, sz);
        if (match.n<0) { return false; }
        if (match.n==0) { match.n = sz/3; }
        match.pos = match.vec[0] + 1;
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


using namespace std;


//TODO: const string CONF_DIR = "/etc/nginx/conf.d/";
const string CONF_DIR = "";

const string LAN_LISTEN = "/var/lib/nginx/lan.listen";
const string LAN_SSL_LISTEN = "/var/lib/nginx/lan_ssl.listen";
const string ADD_SSL_FCT = "add_ssl";
// NAME="_lan"
// PREFIX="/etc/nginx/conf.d/_lan"

class Line {
public:
    typedef const string (*fn)(const string & parameter, const string & begin);
    Line(fn str, const string rgx) : STR{str}, RGX{rgx} {}
    fn STR;
    const regex RGX;
};
    
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



string read_file(const string & filename);
string read_file(const string & filename) 
{
    ifstream file(filename, ios::in|ios::ate);
    string str = "";
    if (file.good()) {
        size_t size = file.tellg();
        str.reserve(size);
        file.seekg(0);
        str.assign((istreambuf_iterator<char>(file)),
                istreambuf_iterator<char>());
    }
    file.close();
    return str;
}

void write_file(const string & filename, const string str, 
                ios_base::openmode flag=ios::trunc);
void write_file(const string & filename, const string str, 
                ios_base::openmode flag)
{
    ofstream file (filename, ios::out|flag);
    if (file.good()) { file<<str<<endl; }
    file.close();    
}





string get_if_missed(const string & conf, const Line & LINE, const string & val,
                   const string & begin="\n    ", const int field=2);
string get_if_missed(const string & conf, const Line & LINE, const string & val, 
                   const string & begin, const int field)
{
    smatch match;
//     cout<<conf<<endl;
    while (regex_search(conf, match, LINE.RGX)) {
//         cout<<match[0]<<"-"<<match[1]<<"-"<<match[2]<<"-"<<match[3]<<"-"<<endl;
        const string value = match[field];
        if (value==val || value=="'"+val+"'" || value=='"'+val+'"') {
            return ""; 
        }
    }
    return LINE.STR(val, begin);
}

void add_ssl_directives_to(const string & name, const bool isdefault);
void add_ssl_directives_to(const string & name, const bool isdefault)
{
    const string prefix = CONF_DIR + name;
    string conf = read_file(prefix+".conf");
        
    for (smatch match; regex_search(conf, match, NGX_SERVER_NAME.RGX); ) {
        if (match[2].find(name) == string::npos) { continue; } 
        const string begin = match[1];
        string adds = "";
        adds += isdefault ?
            get_if_missed(conf, NGX_INCLUDE_LAN_SSL_LISTEN_DEFAULT, "",begin) :
            get_if_missed(conf, NGX_INCLUDE_LAN_SSL_LISTEN, "", begin);
        adds += get_if_missed(conf, NGX_SSL_CRT, prefix+".crt", begin);
        adds += get_if_missed(conf, NGX_SSL_KEY, prefix+".key", begin);
        adds += get_if_missed(conf, NGX_SSL_SESSION_CACHE, "", begin);
        adds += get_if_missed(conf, NGX_SSL_SESSION_TIMEOUT, "", begin);
        if (adds.length() > 0) {
            string conf = match.prefix() + match[0] + adds + match.suffix();
            conf = isdefault ?
                   regex_replace(conf, NGX_INCLUDE_LAN_LISTEN_DEFAULT.RGX,"") :
                   regex_replace(conf, NGX_INCLUDE_LAN_LISTEN.RGX, "");
            write_file(prefix+".conf", conf);
            cout<<"Added SSL directives to "<<prefix<<".conf:"<<adds<<endl;
        }
        return ;
    }
    cout<<"Cannot add SSL directives to "<<prefix<<".conf, missing:";
    cout<<NGX_SERVER_NAME.STR(name, "\n    ")<<endl;
}

int call(const char program[], const char arg[]);
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

void try_using_cron_to_recreate_certificate(const string & name);
void try_using_cron_to_recreate_certificate(const string & name) 
{
#ifdef openwrt
    const string conf = read_file("/etc/crontabs/root");
#else 
    const string conf = read_file("crontabs");
#endif
    const string CRON_CHECK = "3 3 12 12 *";
    const string add = get_if_missed(conf, CRON_CMD, name, "", 1);
    if (add.length() > 0) {
#ifdef openwrt
        int status;
        waitpid(call("/etc/init.d/cron", "status"), &status, 0);
        if (status != 0) {
            cout<<"Cron unavailable to re-create the ssl certificate for '";
            cout<<name<<"'."<<endl;
        } else 
#endif
        {
            call("/etc/init.d/cron", "reload");
            
#ifdef openwrt
            write_file("/etc/crontabs/root", CRON_CHECK+add, ios::app);
#else 
            write_file("crontabs", CRON_CHECK+add, ios::app);
#endif
            cout<<"Rebuild the ssl certificate for '";
            cout<<name<<"' annually with cron."<<endl;
        }
    }
}

#ifdef openwrt
string create_lan_listen_process(blob_attr * attr, size_t len, bool inner=false); 
string create_lan_listen_process(blob_attr * attr, size_t len, bool inner) {
    string listen = "# This file is re-created if Nginx starts or"
        " a LAN address changes.\n";
    string listen_default = listen;
    string ssl_listen = listen;
    string ssl_listen_default = listen;
    blob_attr * pos;
    blobmsg_for_each_attr(pos, attr, len) {
        string name = blobmsg_name(pos);
        void * data = blobmsg_data(pos);
        size_t sz = blobmsg_data_len(pos);
        string ip = "";
        if (name == "address") {
            return (char *)data;
        } else if (name == "ipv4-address") {
            ip = create_lan_listen_process((blob_attr *)data, sz);
        } else if (name == "ipv6-address") {
            ip = "[" + create_lan_listen_process((blob_attr *)data, sz) + "]";
        } 
        if (ip != "" && ip != "[]") {
            listen += "     listen " + ip + ":80;\n";
            listen_default += "     listen " + ip + ":80 default_server;\n";
            ssl_listen += "     listen " + ip + ":443 ssl;\n";
            ssl_listen_default += "     listen " + ip + 
                ":443 ssl default_server;\n";
        }
    }
    if (inner) { return ""; }
    listen += "     listen 127.0.0.1:80;\n";
    listen += "     listen [::1]:80;\n";
    listen_default += "     listen 127.0.0.1:80 default_server;\n";
    listen_default += "     listen [::1]:80 default_server;\n";
    ssl_listen += "     listen 127.0.0.1:443 ssl;\n";
    ssl_listen += "     listen [::1]:443 ssl;\n";
    ssl_listen_default += "     listen 127.0.0.1:443 ssl default_server;\n";
    ssl_listen_default += "     listen [::1]:443 ssl default_server;\n";
    write_file(LAN_LISTEN, listen);
    write_file(LAN_LISTEN+".default", listen_default);
    write_file(LAN_SSL_LISTEN, ssl_listen);
    write_file(LAN_SSL_LISTEN+".default", ssl_listen_default);
    return "";
}

static void create_lan_listen_cb(ubus_request * req, int type, blob_attr * msg);
static void create_lan_listen_cb(ubus_request * req, int type, blob_attr * msg)
{
    if (!msg) { return; }
    create_lan_listen_process(msg, blobmsg_data_len(msg));
}

static int create_lan_listen();
static int create_lan_listen()
{
    ubus_context * ctx = ubus_connect(NULL);
    if (ctx==NULL) { return -1; }
    uint32_t id;
    int ret = ubus_lookup_id(ctx, "network.interface.lan", &id);
    if (ret==0) {
        static blob_buf req;
        blob_buf_init(&req, 0);
        ret = ubus_invoke(ctx, id, "status", req.head, 
                          create_lan_listen_cb, NULL, 200);
    }
    if (ctx) { ubus_free(ctx); }
    return ret;
}

#endif

    
int main(int argc, char * argv[]) {
    auto begin = chrono::steady_clock::now();
    if (argc != 2) {
        cout<<"syntax: "<<argv[0]<<" server_name"<<endl;
        return 2;
    }
    const string name = argv[1];

    auto 
    end = chrono::steady_clock::now();
    cout << "Time difference = " <<
    chrono::duration_cast<chrono::milliseconds>(end - begin).count()
    << " ms" << endl;
    begin = chrono::steady_clock::now();
    
    for (int i=0; i<1; ++i) {
        
#ifdef openwrt
    create_lan_listen();
    
    end = chrono::steady_clock::now();
    cout << "Time difference = " <<
    chrono::duration_cast<chrono::milliseconds>(end - begin).count()
    << " ms" << endl;
    begin = chrono::steady_clock::now();
#endif
    
    add_ssl_directives_to(name, name=="_lan");
    
    end = chrono::steady_clock::now();
    cout << "Time difference = " <<
    chrono::duration_cast<chrono::milliseconds>(end - begin).count()
    << " ms" << endl;
    begin = chrono::steady_clock::now();
    
    try_using_cron_to_recreate_certificate(name);
    
    }
    end = chrono::steady_clock::now();
    cout << "Time difference = " <<
    chrono::duration_cast<chrono::milliseconds>(end - begin).count()
    << " ms" << endl;
    begin = chrono::steady_clock::now();
    
    return 0;
}

//TODO: _lan.conf # as seen by: ubus call network.interface.lan status | grep '"address"'
 
