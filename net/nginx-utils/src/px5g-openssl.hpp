#ifndef __PX5G_OPENSSL_H
#define __PX5G_OPENSSL_H

#include <string>
#include <openssl/bio.h>

#include <openssl/x509.h>
#include <openssl/pem.h>
#include <openssl/err.h>

bool checkend(const char * infile, const time_t seconds=0, bool use_pem=true);
bool checkend(const char * infile, const time_t seconds, bool use_pem)
{
    BIO * cert = infile==NULL ?
        BIO_new_fp(stdin, BIO_NOCLOSE | (use_pem ? BIO_FP_TEXT : 0) ) :
        BIO_new_file(infile, (use_pem ? "r" : "rb") );

    const X509 * x509 = NULL;

    if (cert) {
        x509 = use_pem ?
            PEM_read_bio_X509_AUX(cert, NULL, NULL, NULL) :
            d2i_X509_bio(cert, NULL);
        BIO_free(cert);
    }

    auto print_error = [](const char * str, size_t len, void * errmsg) -> int {
        *(std::string *)errmsg += str;
        return 0;
    };
    if (x509==NULL) {
        std::string errmsg{"checkend error: unable to load certificate\n"};
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg.c_str());
    }

    time_t checktime = time(NULL) + seconds;

    return (X509_cmp_time(X509_get0_notAfter(x509), &checktime) >= 0);
}

#endif
