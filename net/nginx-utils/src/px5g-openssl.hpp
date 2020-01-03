#ifndef __PX5G_OPENSSL_H
#define __PX5G_OPENSSL_H

#include <string>
#include <memory>
#include <openssl/pem.h>
#include <openssl/err.h>

using EVP_PKEY_ptr = std::unique_ptr<EVP_PKEY, decltype(&::EVP_PKEY_free)>;

inline int print_error(const char str[], const size_t len, void * errmsg);
inline int print_error(const char str[], const size_t len, void * errmsg)
{
    *(std::string *)errmsg += str;
    return 0;
}


bool checkend(const char crtpath[],
              const time_t seconds=0, const bool use_pem=true);
bool checkend(const char crtpath[],
              const time_t seconds, const bool use_pem)
{
    BIO * bio = crtpath==NULL ?
        BIO_new_fp(stdin, BIO_NOCLOSE | (use_pem ? BIO_FP_TEXT : 0)) :
        BIO_new_file(crtpath, (use_pem ? "r" : "rb"));

    X509 * x509 = NULL;

    if (bio) {
        x509 = use_pem ?
            PEM_read_bio_X509_AUX(bio, NULL, NULL, NULL) :
            d2i_X509_bio(bio, NULL);
        BIO_free(bio);
    }

    if (x509==NULL) {
        std::string errmsg{"checkend error: unable to load certificate\n"};
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg.c_str());
    }

    time_t checktime = time(NULL) + seconds;
    auto cmp = X509_cmp_time(X509_get0_notAfter(x509), &checktime);

    X509_free(x509);

    return (cmp >= 0);
}


// BIO * bio_open_owner(const char keypath[], const bool use_pem=true);
// BIO * bio_open_owner(const char keypath[], const bool use_pem)
// {
//     BIO * bio = NULL;
//
//     if (!keypath) {
//         bio = BIO_new_fp(stdout, BIO_NOCLOSE | (use_pem ? BIO_FP_TEXT : 0));
//
//     } else {
//         //BIO_new_file(keypath, (use_pem ? "w" : "wb") );
//
//         auto fd = open(keypath, O_WRONLY | O_CREAT | O_TRUNC, 0600);
//
//         if (fd >= 0) {
//             auto fp = fdopen(fd, (use_pem ? "w" : "wb") );
//
//             if (fp) {
//                 bio = BIO_new_fp(fp, BIO_CLOSE | (use_pem ? BIO_FP_TEXT : 0));
//                 if (!bio) {
//                     fclose(fp);
//                 }
//             } else {
//                 close(fd);
//             }
//         }
//     }
//
//     if (!bio) {
//         std::string errmsg{"cannot open for writing "};
//         errmsg += keypath==NULL ? "stdout" : keypath;
//         errmsg += "\n";
//         ERR_print_errors_cb(print_error, &errmsg);
//         throw std::runtime_error(errmsg.c_str());
//     }
//
//     return bio;
// }



void write_key(const EVP_PKEY_ptr & pkey,
               const char keypath[]=NULL, const bool use_pem=true);
void write_key(const EVP_PKEY_ptr & pkey,
               const char keypath[], const bool use_pem)
{
    BIO * bio = NULL;

    if (!keypath) {
        bio = BIO_new_fp(stdout, BIO_NOCLOSE | (use_pem ? BIO_FP_TEXT : 0));

    } else {
        //BIO_new_file(keypath, (use_pem ? "w" : "wb") );

        auto fd = open(keypath, O_WRONLY | O_CREAT | O_TRUNC, 0600);

        if (fd >= 0) {
            auto fp = fdopen(fd, (use_pem ? "w" : "wb") );

            if (fp) {
                bio = BIO_new_fp(fp, BIO_CLOSE | (use_pem ? BIO_FP_TEXT : 0));
                if (!bio) {
                    fclose(fp);
                }
            } else {
                close(fd);
            }
        }
    }

    if (!bio) {
        std::string errmsg{"cannot open for writing "};
        errmsg += keypath==NULL ? "stdout" : keypath;
        errmsg += "\n";
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg.c_str());
    }

    int len = 0;

    auto key = pkey.get();
    switch (EVP_PKEY_base_id(key)) { // use same format as px5g:
        case EVP_PKEY_EC:
            len = use_pem ?
                PEM_write_bio_ECPrivateKey(bio, EVP_PKEY_get0_EC_KEY(key),
                                            NULL, NULL, 0, NULL, NULL) :
                i2d_ECPrivateKey_bio(bio, EVP_PKEY_get0_EC_KEY(key));
            break;
        case EVP_PKEY_RSA:
            len = use_pem ?
                PEM_write_bio_RSAPrivateKey(bio, EVP_PKEY_get0_RSA(key),
                                            NULL, NULL, 0, NULL, NULL) :
                i2d_RSAPrivateKey_bio(bio, EVP_PKEY_get0_RSA(key));
            break;
        default:
            len = use_pem ?
                PEM_write_bio_PrivateKey(bio, key, NULL, NULL, 0, NULL, NULL) :
                i2d_PrivateKey_bio(bio, key);
    }

    BIO_free_all(bio);

    if (len==0) {
        std::string errmsg{"write_key error: cannot write EVP pkey to "};
        errmsg += keypath==NULL ? "stdout" : keypath;
        errmsg += "\n";
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg.c_str());
    }
}


auto gen_eckey(const int curve);
auto gen_eckey(const int curve)
{
    EC_GROUP * group = curve ? EC_GROUP_new_by_curve_name(curve) : NULL;

    if (!group) {
        std::string errmsg{"gen_eckey error: cannot build group for curve id "};
        errmsg += std::to_string(curve) + "\n";
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg.c_str());
    }

    EC_GROUP_set_asn1_flag(group, OPENSSL_EC_NAMED_CURVE);

    EC_GROUP_set_point_conversion_form(group, POINT_CONVERSION_UNCOMPRESSED);

    auto eckey = EC_KEY_new();

    if (eckey) {
        if (!EC_KEY_set_group(eckey, group) || !EC_KEY_generate_key(eckey)) {
            EC_KEY_free(eckey);
            eckey = NULL;
        }
    }

    EC_GROUP_free(group);

    if (!eckey) {
        std::string errmsg{"gen_eckey error: cannot build key with curve id "};
        errmsg += std::to_string(curve) + "\n";
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg.c_str());
    }

    EVP_PKEY_ptr pkey{EVP_PKEY_new(), ::EVP_PKEY_free};

    if (!EVP_PKEY_assign_EC_KEY(pkey.get(), eckey)) {
        EC_KEY_free(eckey);
        std::string errmsg{"gen_eckey error: cannot assign EC key to EVP\n"};
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg.c_str());
    }

    return pkey;
}


auto gen_rsakey(const int keysize, const unsigned long exponent=RSA_F4);
auto gen_rsakey(const int keysize, const unsigned long exponent)
{
    if (keysize<512 || keysize>OPENSSL_RSA_MAX_MODULUS_BITS) {
        std::string errmsg{"gen_rsakey error: RSA keysize ("};
        errmsg += std::to_string(keysize) + ") out of range [512..";
        errmsg += std::to_string(OPENSSL_RSA_MAX_MODULUS_BITS) + "]";
        throw std::runtime_error(errmsg.c_str());
    }
    auto bignum = BN_new();

    if (!bignum) {
        std::string errmsg{"gen_rsakey error: cannot get big number struct\n"};
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg.c_str());
    }

    auto rsa = RSA_new();

    if (rsa) {
        if (!BN_set_word(bignum, exponent) ||
            !RSA_generate_key_ex(rsa, keysize, bignum, NULL))
        {
            RSA_free(rsa);
            rsa = NULL;
        }
    }

    BN_free(bignum);

    if (!rsa) {
        std::string errmsg{"gen_rsakey error: cannot create RSA key with size"};
        errmsg += std::to_string(keysize) + " and exponent ";
        errmsg += std::to_string(exponent) + "\n";
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg.c_str());
    }

    EVP_PKEY_ptr pkey{EVP_PKEY_new(), ::EVP_PKEY_free};

    if (!EVP_PKEY_assign_RSA(pkey.get(), rsa)) {
        RSA_free(rsa);
        std::string errmsg{"gen_rsakey error: cannot assign RSA key to EVP\n"};
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg.c_str());
    }

    return pkey;
}


auto subject2name(const char subject[]);
auto subject2name(const char subject[])
{
    if (subject && subject[0]!='/') {
        throw std::runtime_error("subject2name errror: not starting with /");
    }

    auto name = X509_NAME_new();

    if (!name) {
        std::string errmsg{"subject2name error: cannot create X509 name \n"};
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg.c_str());
    }

    if (!subject) { return name; }

    size_t prev = 1;
    std::string type = "";
    char chr = '=';
    for (size_t i=0; subject[i]; ) {
        ++i;
        if (subject[i]=='\\' && subject[++i]=='\0') {
            X509_NAME_free(name);
            throw std::runtime_error("subject2name errror: escape at the end");
        }
        if (subject[i]!=chr && subject[i]!='\0') { continue; }
        if (chr == '=') {
            type = std::string(&subject[prev], i-prev);
            chr = '/';
        } else {
            auto nid = OBJ_txt2nid(type.c_str());
            if (nid == NID_undef) {
                // skip unknown entries (silently?).
            } else {
                auto val = &subject[prev];
                auto len = i - prev;
                if (!X509_NAME_add_entry_by_NID(name, nid, MBSTRING_ASC,
                                    (const unsigned char *)val, len, -1, 0))
                {
                    X509_NAME_free(name);
                    std::string errmsg{"subject2name error: cannot add "};
                    errmsg += "/" + type + "=" + std::string(val, len) + "\n";
                    ERR_print_errors_cb(print_error, &errmsg);
                    throw std::runtime_error(errmsg.c_str());
                }
            }
            chr = '=';
        }
        prev = i+1;
    }

    return name;
}


void selfsigned(const EVP_PKEY_ptr & pkey, const char subject[]="",
                const unsigned long days=30, const char crtpath[]=NULL,
                const bool use_pem=true);
void selfsigned(const EVP_PKEY_ptr & pkey, const char subject[],
                const unsigned long days, const char crtpath[],
                const bool use_pem)
{
    auto x509 = X509_new();

    if (!x509) {
        std::string errmsg{"selfsigned error: cannot create X509 structure\n"};
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg.c_str());
    }

    auto freeX509_and_throw = [&x509](std::string what) -> void
    {
        if (x509) { X509_free(x509); }
        std::string errmsg{"selfsigned error: cannot set "};
        errmsg += what + " in X509 certificate\n";
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg.c_str());
    };

    if (!X509_set_version(x509, 2)) { freeX509_and_throw("version"); }

    if (!X509_set_pubkey(x509, pkey.get())) { freeX509_and_throw("pubkey"); }

    if (!X509_gmtime_adj(X509_getm_notBefore(x509), 0) ||
        !X509_time_adj_ex(X509_getm_notAfter(x509), days, 0, NULL))
    {
        freeX509_and_throw("times");
    }

    try {
        auto name = subject2name(subject);

        if (!X509_set_subject_name(x509, name)) {
            X509_NAME_free(name);
            freeX509_and_throw("subject");
        }

        if (!X509_set_issuer_name(x509, name)) {
            X509_NAME_free(name);
            freeX509_and_throw("issuer");
        }

    } catch (...) {
        X509_free(x509);
        throw;
    }

    auto bignum = BN_new();
    if (!bignum) { freeX509_and_throw("serial (creating big number struct)"); }
    if (!BN_rand(bignum, 159, BN_RAND_TOP_ANY, BN_RAND_BOTTOM_ANY)) {
        BN_free(bignum);
        freeX509_and_throw("serial (creating random number)");
    }
    if (!BN_to_ASN1_INTEGER(bignum, X509_get_serialNumber(x509))) {
        BN_free(bignum);
        freeX509_and_throw("random serial");
    }
    BN_free(bignum);

    if (!X509_sign(x509, pkey.get(), EVP_sha256())) {
        freeX509_and_throw("signing digest");
    }

    BIO * bio = crtpath==NULL ?
        BIO_new_fp(stdout, BIO_NOCLOSE | (use_pem ? BIO_FP_TEXT : 0)) :
        BIO_new_file(crtpath, (use_pem ? "w" : "wb"));

    int len = 0;

    if (bio) {
        len = use_pem ?
            PEM_write_bio_X509(bio, x509) :
            i2d_X509_bio(bio, x509);
        BIO_free_all(bio);
    }

    X509_free(x509);

    if (len==0) {
        std::string errmsg{"selfsigned error: cannot write certificate to "};
        errmsg += crtpath==NULL ? "stdout" : crtpath;
        errmsg += "\n";
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg.c_str());
    }
}


#endif
