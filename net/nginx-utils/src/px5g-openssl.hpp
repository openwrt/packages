#ifndef __PX5G_OPENSSL_H
#define __PX5G_OPENSSL_H

#include <string>
#include <openssl/bio.h>

#include <openssl/x509.h>
#include <openssl/pem.h>
#include <openssl/err.h>

int print_error(const char str[], size_t len, void * errmsg);
int print_error(const char str[], size_t len, void * errmsg)
{
    *(std::string *)errmsg += str;
    return 0;
}

bool checkend(const char infile[],
              const time_t seconds=0, const bool use_pem=true);
bool checkend(const char infile[], const time_t seconds, const bool use_pem)
{
    BIO * cert = infile==NULL ?
        BIO_new_fp(stdin, BIO_NOCLOSE | (use_pem ? BIO_FP_TEXT : 0)) :
        BIO_new_file(infile, (use_pem ? "r" : "rb"));

    const X509 * x509 = NULL;

    if (cert) {
        x509 = use_pem ?
            PEM_read_bio_X509_AUX(cert, NULL, NULL, NULL) :
            d2i_X509_bio(cert, NULL);
        BIO_free(cert);
    }

    if (x509==NULL) {
        std::string errmsg{"checkend error: unable to load certificate\n"};
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg.c_str());
    }

    time_t checktime = time(NULL) + seconds;

    return (X509_cmp_time(X509_get0_notAfter(x509), &checktime) >= 0);
}


BIO * bio_open_owner(const char keyfile[], const bool use_pem=true);
BIO * bio_open_owner(const char keyfile[], const bool use_pem)
{
    BIO * bio = NULL;

    if (!keyfile) {
        bio = BIO_new_fp(stdout, BIO_NOCLOSE | (use_pem ? BIO_FP_TEXT : 0));

    } else {
        //BIO_new_file(keyfile, (use_pem ? "w" : "wb") );

        auto fd = open(keyfile, O_WRONLY | O_CREAT | O_TRUNC, 0600);

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
        errmsg += keyfile==NULL ? "stdout" : keyfile;
        errmsg += "\n";
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg.c_str());
    }

    return bio;
}


void write_key(const char keyfile[], EC_KEY * const eckey,
               const bool use_pem=true);
void write_key(const char keyfile[], EC_KEY * const eckey, const bool use_pem)
{
    auto bio = bio_open_owner(keyfile);

    int len = use_pem ?
        PEM_write_bio_ECPrivateKey(bio, eckey, NULL, NULL, 0, NULL, NULL) :
        i2d_ECPrivateKey_bio(bio, eckey);

    BIO_free_all(bio);

    if (len==0) {
        std::string errmsg{"cannot write eckey to "};
        errmsg += keyfile==NULL ? "stdout" : keyfile;
        errmsg += "\n";
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg.c_str());
    }
}


EC_KEY * gen_eckey(const int curve);
EC_KEY * gen_eckey(const int curve)
{
    EC_GROUP * group = curve ? EC_GROUP_new_by_curve_name(curve) : NULL;

    if (!group) {
        std::string errmsg{"invalid elliptic curve name"};
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
        std::string errmsg{"cannot create elliptic curve key with curve id"};
        errmsg += std::to_string(curve) + "\n";
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg.c_str());
    }

    return eckey;
}


RSA * gen_rsakey(const int keysize, const unsigned long exponent=RSA_F4);
RSA * gen_rsakey(const int keysize, const unsigned long exponent)
{
    if (keysize<0 || keysize>OPENSSL_RSA_MAX_MODULUS_BITS) {
        throw std::runtime_error("RSA keysize out of range");
    }
    auto bignum = BN_new();

    if (!bignum) {
        std::string errmsg{"cannot initialize big number structure"};
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
        std::string errmsg{"cannot create rsa key with size"};
        errmsg += std::to_string(keysize) + " and exponent ";
        errmsg += std::to_string(exponent) + "\n";
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg.c_str());
    }

    return rsa;
}


void write_key(const char keyfile[], RSA * const rsakey, bool use_pem=true);
void write_key(const char keyfile[], RSA * const rsakey, bool use_pem)
{
    auto bio = bio_open_owner(keyfile);

    int len = use_pem ?
        PEM_write_bio_RSAPrivateKey(bio, rsakey, NULL, NULL, 0, NULL, NULL) :
        i2d_RSAPrivateKey_bio(bio, rsakey);

    BIO_free_all(bio);

    if (len==0) {
        std::string errmsg{"cannot write rsakey to "};
        errmsg += keyfile==NULL ? "stdout" : keyfile;
        errmsg += "\n";
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg.c_str());
    }
}

#endif
