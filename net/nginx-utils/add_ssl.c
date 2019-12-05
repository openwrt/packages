// _add_ssl_if_needed() {
//     [ ${#} -eq 2 ] || return 2
//     # 1. argument: [domain name] (use _ for LAN)
//     # 2. argument: [assume-expired-as-default|assume-valid-as-default]
//     # return: 0 if there is a valid certificate (before or now), else 1.
//     # CRON_CHECK="3 3 12 12 *" # all 12 months (on each 12.12. at 03:03)
//     # REMAINING="34300800" # about 13 months > ${CRON_CHECK}
//     # LIFE_TIME="1188" # about 39 months > 2*${CRON_CHECK} + ${REMAINING}
//     local ASSUME="${2}"
//     local DEFAULT=".default"
//     if [ "${1}" != "${NAME}" ]
//     then
//         DEFAULT=""
//         NAME="${1}"
//         PREFIX="/etc/nginx/conf.d/${NAME}"
//     fi
//     local GENKEY_CMD
//     GENKEY_CMD="\
//         $(_is_certificate_valid_else_echo_genkey_cmd "${NAME}" "${ASSUME}")" \
//     && _add_ssl_directives_to_server_conf "${NAME}" "${DEFAULT}" \
//     && _try_using_cron_to_recreate_certificate "${NAME}" \
//     && return 0
//     [ -z "${GENKEY_CMD}" ] \
//     && echo "Cannot create create ssl certificate, no binary found." \
//     && _remove_ssl_directives_from_server_conf "${NAME}" "${DEFAULT}" \
//     && return 1
//     _create_ssl_certificate "${NAME}" "${GENKEY_CMD}" \
//     || return 1
//     _add_ssl_directives_to_server_conf "${NAME}" "${DEFAULT}"
//     _try_using_cron_to_recreate_certificate "${NAME}"
//     return 0
// } 


// class AddSSL {
// public:
//     AddSSL(const char * prefix) : prefix(cut_off_dot_conf(filename)) {
//         
//     }
//     
// private:
//     string cut_off_dot_conf(char * filename) {
//         
//     }
//     const string lan = "_lan";
//     const string prefix;
// }

enum Assume { EXPIRED_AS_DEFAULT, VALID_AS_DEFAULT };
const time_t remaining = 34300800;
const char cron_check = "3 3 12 12 *";
const char lan = "_lan";
const string conf_dir = "/etc/nginx/conf.d/";
const string lan_listen = "/var/lib/nginx/lan.listen";
const string lan_ssl_listen = "/var/lib/nginx/lan_ssl.listen";

string ngx_include(const string & insert) {
    return "    include '"+insert+"';";
}
string ngx_server_name(const string & insert) {
    return "    server_name * '"+insert+"' *;";
}
string ngx_ssl_crt(const string & insert) {
    return "    ssl_certificate '"+insert+".crt';";
}
string ngx_ssl_key(const string & insert) {
    return "    ssl_certificate_key '"+insert+".key';";
}
string ngx_ssl_session_cache(const string & insert) {
    return "    ssl_session_cache shared:SSL:32k;";
}
string ngx_ssl_session_timeout(const string & insert) {
    return "    ssl_session_timeout 64m;";
}



void try_using_cron_to_recreate_certificate(const string & name) {
    
}

void add_ssl_to_server_conf(const string & name, const string & suffix) {
    string conf = conf_dir+name+".conf"; //TODO get from file.
    string adds = "";
    // if (!regex)
    adds += ngx_include(lan_ssl_listen+suffix);
    // if (!regex)
    adds += ngx_ssl_crt(conf_dir+name);
    // if (!regex)
    adds += ngx_ssl_key(conf_dir+name);
    // if (!regex)
    adds += ngx_ssl_session_cache(name);
    // if (!regex)
    adds += ngx_ssl_session_timeout("");
    if (adds != "") {
        if () {
            cout<<"Addded directives to "<<conf_dir+name+".conf:"<<adds<<endl;
        } else {
            cout<<"Cannot add directives to "<<conf_dir+name+".conf, missing:";
            cout<<"\n"<<ngx_server_name(name)<<adds<<endl;
        }
    }
    
//     then
//         ADDS="$(echo "${ADDS}" | sed -E 's/^\\n//')"
//         echo "${CONF}" | grep -qE "$(_regex "${NGX_SERVER_NAME}" "${NAME}")" \
//         && echo "${CONF}" \
//             | sed -E "/$(_regex "${NGX_SERVER_NAME}" "${NAME}")/a\\${ADDS}" \
//             > "${PREFIX}.conf" \
//         && _echo_sed "Added directives to ${PREFIX}.conf:\n${ADDS}" \
//         || _echo_sed "Cannot add directives to ${PREFIX}.conf, missing:\
//             \n$(_sed_rhs "${NGX_SERVER_NAME}" "${NAME}")\n${ADDS}"
//     fi
//     return 0
}

void remove_ssl_to_server_conf(const string & name, const string & suffix) {
    
}

bool is_certificate_valid(const string & name) {
    // return file_exists(conf_dir+name+".key") && 
    return checkend(conf_dir+name+".crt", remaining);
}

bool create_ssl_certificate(const string & name) {
    return true;
}

int add_ssl_if_needed(const string & name, const Assume assuming) {
    const string suffix = strcmp(name, lan)==0 ? ".default" : "";
    int ret = 0;
    if (is_certificate_valid(prefix) || create_ssl_certificate(name)) {
        add_ssl_to_server_conf(name, suffix);
        try_using_cron_to_recreate_certificate(name);
    } else {
        remove_ssl_from_server_conf(name, suffix);
        ret = 1;
    }
    return ret;
}

int main(int argc, char argv[][]) {
    if (argc==0) { return 2; }
    Assume assuming = EXPIRED_AS_DEFAULT;
    char name[];
    for (int i=0; i<argc; ++i) {
        if (argv[i][0]!='-') {
            name = argv[i];
        } else if (strcmp(argv[i], "--assume-valid-as-default")==0) {
            assuming = VALID_AS_DEFAULT;
        }
    }
    return add_ssl_if_needed(name, assuming);
}
 
 
 
bool checkend(const string & filename, const time_t checkoffset) {
    // x = get cert from filename
        time_t tcheck = time(NULL) + checkoffset;
//         if (X509_cmp_time(X509_get0_notAfter(x), &tcheck) < 0) {
// //             BIO_printf(out, "Certificate will expire\n");
//             ret = 1;
//         } else {
// //             BIO_printf(out, "Certificate will not expire\n");
//             ret = 0;
//         }
//         return ret;
        return true;
}
// 
// 
// void req() {
//     cipher = NULL;
//     genctx = set_keygen_ctx("ec", &pkey_type, &newkey,
//                                     &keyalgstr, gen_eng);
//     char *genopt = "ec_paramgen_curve:secp384r1";
//     if (pkey_ctrl_string(genctx, genopt) <= 0) {
// //         BIO_printf(bio_err, "parameter error \"%s\"\n", genopt);
// //         goto end;
//     }
// //         if (pkey == NULL) {
// //             BIO_printf(bio_err, "you need to specify a private key\n");
// //         }
//     req = X509_REQ_new();
//     if (req == NULL) {
// //         goto end;
//     }
//     i = make_REQ(req, pkey, subj, multirdn, !x509, chtype);
//     if (!i) {
// //         BIO_printf(bio_err, "problems making Certificate Request\n");
// //         goto end;
//     }
//     EVP_PKEY *tmppkey;
//     X509V3_CTX ext_ctx;
//     if ((x509ss = X509_new()) == NULL)
//         goto end;
//     /* Set version to V3 */
//     if ((extensions != NULL || addext_conf != NULL)
//         && !X509_set_version(x509ss, 2))
//         goto end;
//     if (serial != NULL) {
//         if (!X509_set_serialNumber(x509ss, serial))
//             goto end;
//     } else {
//         if (!rand_serial(NULL, X509_get_serialNumber(x509ss)))
//             goto end;
//     }
//     if (!X509_set_issuer_name(x509ss, X509_REQ_get_subject_name(req)))
//         goto end;
//     if (!set_cert_times(x509ss, NULL, NULL, days))
//         goto end;
//     if (!X509_set_subject_name
//         (x509ss, X509_REQ_get_subject_name(req)))
//         goto end;
//     tmppkey = X509_REQ_get0_pubkey(req);
//     if (!tmppkey || !X509_set_pubkey(x509ss, tmppkey))
//         goto end;
//     /* Set up V3 context struct */
//     X509V3_set_ctx(&ext_ctx, x509ss, x509ss, NULL, NULL, 0);
//     X509V3_set_nconf(&ext_ctx, req_conf);
//     /* Add extensions */
//     if (extensions != NULL && !X509V3_EXT_add_nconf(req_conf,
//                                                     &ext_ctx, extensions,
//                                                     x509ss)) {
// //         BIO_printf(bio_err, "Error Loading extension section %s\n",
// //                     extensions);
// //         goto end;
//     }
//     if (addext_conf != NULL
//         && !X509V3_EXT_add_nconf(addext_conf, &ext_ctx, "default",
//                                     x509ss)) {
// //         BIO_printf(bio_err, "Error Loading command line extensions\n");
// //         goto end;
//     }
//     i = do_X509_sign(x509ss, pkey, digest, sigopts);
//     if (!i) {
//         ERR_print_errors(bio_err);
//         goto end;
//     }
// }
