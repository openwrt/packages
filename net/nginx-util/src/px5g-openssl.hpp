#ifndef _PX5G_OPENSSL_HPP
#define _PX5G_OPENSSL_HPP

#include <fcntl.h>
#include <openssl/bn.h>
#include <openssl/err.h>
#include <openssl/pem.h>
#include <openssl/rsa.h>
#include <openssl/evp.h>
#include <unistd.h>
#include <memory>
#include <stdexcept>
#include <string>

static constexpr auto rsa_min_modulus_bits = 512;

using EVP_PKEY_ptr = std::unique_ptr<EVP_PKEY, decltype(&::EVP_PKEY_free)>;

using X509_NAME_ptr = std::unique_ptr<X509_NAME, decltype(&::X509_NAME_free)>;

auto checkend(const std::string& crtpath, time_t seconds = 0, bool use_pem = true) -> bool;

auto gen_eckey(int curve) -> EVP_PKEY_ptr;

auto gen_rsakey(int keysize) -> EVP_PKEY_ptr;

void write_key(const EVP_PKEY_ptr& pkey, const std::string& keypath = "", bool use_pem = true);

auto subject2name(const std::string& subject) -> X509_NAME_ptr;

void selfsigned(const EVP_PKEY_ptr& pkey,
                int days,
                const std::string& subject = "",
                const std::string& crtpath = "",
                bool use_pem = true);

// ------------------------- implementation: ----------------------------------

inline auto print_error(const char* str, const size_t /*len*/, void* errmsg) -> int
{
    *static_cast<std::string*>(errmsg) += str;
    return 0;
}

// wrapper for clang-tidy:
inline auto _BIO_new_fp(FILE* stream, const bool use_pem, const bool close = false) -> BIO*
{
    return BIO_new_fp(stream,  // NOLINTNEXTLINE(hicpp-signed-bitwise) macros:
                      (use_pem ? BIO_FP_TEXT : 0) | (close ? BIO_CLOSE : BIO_NOCLOSE));
}

auto checkend(const std::string& crtpath, const time_t seconds, const bool use_pem) -> bool
{
    BIO* bio = crtpath.empty() ? _BIO_new_fp(stdin, use_pem)
                               : BIO_new_file(crtpath.c_str(), (use_pem ? "r" : "rb"));

    X509* x509 = nullptr;

    if (bio != nullptr) {
        x509 = use_pem ? PEM_read_bio_X509_AUX(bio, nullptr, nullptr, nullptr)
                       : d2i_X509_bio(bio, nullptr);
        BIO_free(bio);
    }

    if (x509 == nullptr) {
        std::string errmsg{"checkend error: unable to load certificate\n"};
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg);
    }

    time_t checktime = time(nullptr) + seconds;
    auto cmp = X509_cmp_time(X509_get0_notAfter(x509), &checktime);

    X509_free(x509);

    return (cmp >= 0);
}

auto gen_eckey(const int curve) -> EVP_PKEY_ptr
{
    EC_GROUP* group = curve != 0 ? EC_GROUP_new_by_curve_name(curve) : nullptr;

    if (group == nullptr) {
        std::string errmsg{"gen_eckey error: cannot build group for curve id "};
        errmsg += std::to_string(curve) + "\n";
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg);
    }

    EC_GROUP_set_asn1_flag(group, OPENSSL_EC_NAMED_CURVE);
    EC_GROUP_set_point_conversion_form(group, POINT_CONVERSION_UNCOMPRESSED);

    EVP_PKEY_CTX* ctx = EVP_PKEY_CTX_new_id(EVP_PKEY_EC, nullptr);

    if (!ctx || !EVP_PKEY_paramgen_init(ctx)) {
        EC_GROUP_free(group);
        if (ctx) EVP_PKEY_CTX_free(ctx);
        throw std::runtime_error("gen_eckey error: could not initialize paramgen");
    }

    if (EVP_PKEY_CTX_set_ec_paramgen_curve_nid(ctx, curve) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        EC_GROUP_free(group);
        std::string errmsg{"gen_eckey error: cannot set curve nid\n"};
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg);
    }

    EVP_PKEY* params = nullptr;
    if (EVP_PKEY_paramgen(ctx, &params) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        EC_GROUP_free(group);
        std::string errmsg{"gen_eckey error: cannot generate parameters\n"};
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg);
    }

    EVP_PKEY_CTX_free(ctx);

    std::unique_ptr<EVP_PKEY, decltype(&EVP_PKEY_free)> params_ptr(params, EVP_PKEY_free);

    EVP_PKEY_CTX* key_gen_ctx = EVP_PKEY_CTX_new(params, nullptr);

    if (!key_gen_ctx || EVP_PKEY_keygen_init(key_gen_ctx) <= 0) {
        EC_GROUP_free(group);
        if (key_gen_ctx) EVP_PKEY_CTX_free(key_gen_ctx);
        std::string errmsg{"gen_eckey error: cannot initialize key generation context\n"};
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg);
    }

    EVP_PKEY* pkey = nullptr;
    if (EVP_PKEY_keygen(key_gen_ctx, &pkey) <= 0) {
        EVP_PKEY_CTX_free(key_gen_ctx);
        EC_GROUP_free(group);
        std::string errmsg{"gen_eckey error: cannot generate key pair\n"};
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg);
    }

    EVP_PKEY_CTX_free(key_gen_ctx);
    EC_GROUP_free(group);

    return EVP_PKEY_ptr{pkey, EVP_PKEY_free};
}

auto gen_rsakey(const int keysize) -> EVP_PKEY_ptr
{
    if (keysize < rsa_min_modulus_bits || keysize > OPENSSL_RSA_MAX_MODULUS_BITS) {
        std::string errmsg{"gen_rsakey error: RSA keysize ("};
        errmsg += std::to_string(keysize) + ") out of range [512..";
        errmsg += std::to_string(OPENSSL_RSA_MAX_MODULUS_BITS) + "]";
        throw std::runtime_error(errmsg);
    }

    EVP_PKEY_ptr pkey = {EVP_RSA_gen(keysize), EVP_PKEY_free};

    if (!pkey)  {
        std::string errmsg{"gen_rsakey error: unable to generate RSA key with size: "};
        errmsg += std::to_string(keysize);
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg);
    }

    return pkey;
}

void write_key(const EVP_PKEY_ptr& pkey, const std::string& keypath, const bool use_pem)
{
    BIO* bio = nullptr;

    if (keypath.empty()) {
        bio = BIO_new_fp(stdout, BIO_NOCLOSE);
    }
    else {
        bio = BIO_new_file(keypath.c_str(), use_pem ? "w" : "wb");
    }

    if (bio == nullptr) {
        std::string errmsg{"write_key error: cannot open "};
        errmsg += keypath.empty() ? "stdout" : keypath;
        errmsg += "\n";
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg);
    }

    if (use_pem) {
        if (PEM_write_bio_PrivateKey(bio, pkey.get(), nullptr, nullptr, 0, nullptr, nullptr) != 1) {
            BIO_free_all(bio);
            std::string errmsg{"write_key error: cannot write EVP pkey to "};
            errmsg += keypath.empty() ? "stdout" : keypath;
            errmsg += "\n";
            ERR_print_errors_cb(print_error, &errmsg);
            throw std::runtime_error(errmsg);
        }
    }
    else {
        if (i2d_PrivateKey_bio(bio, pkey.get()) != 1) {
            BIO_free_all(bio);
            std::string errmsg{"write_key error: cannot write EVP pkey to "};
            errmsg += keypath.empty() ? "stdout" : keypath;
            errmsg += "\n";
            ERR_print_errors_cb(print_error, &errmsg);
            throw std::runtime_error(errmsg);
        }
    }

    BIO_free_all(bio);
}

auto subject2name(const std::string& subject) -> X509_NAME_ptr
{
    if (!subject.empty() && subject[0] != '/') {
        throw std::runtime_error("subject2name errror: not starting with /");
    }

    X509_NAME_ptr name = {X509_NAME_new(), X509_NAME_free};

    if (!name) {
        std::string errmsg{"subject2name error: cannot create X509 name \n"};
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg);
    }

    if (subject.empty()) {
        return name;
    }

    int prev = 1;
    std::string type{};
    char chr = '=';
    for (int i = 0; subject[i] != 0;) {
        ++i;
        if (subject[i] == '\\' && subject[++i] == '\0') {
            throw std::runtime_error("subject2name errror: escape at the end");
        }
        if (subject[i] != chr && subject[i] != '\0') {
            continue;
        }
        if (chr == '=') {
            type = subject.substr(prev, i - prev);
            chr = '/';
        }
        else {
            auto nid = OBJ_txt2nid(type.c_str());
            if (nid == NID_undef) {
                // skip unknown entries (silently?).
            }
            else {
                const auto* val =  // X509_NAME_add_entry_by_NID wants it unsigned:
                                   // NOLINTNEXTLINE(cppcoreguidelines-pro-type-reinterpret-cast)
                    reinterpret_cast<const unsigned char*>(&subject[prev]);

                int len = i - prev;

                if (X509_NAME_add_entry_by_NID(
                        name.get(), nid,
                        MBSTRING_ASC,  // NOLINT(hicpp-signed-bitwise) is macro
                        val, len, -1, 0) == 0)
                {
                    std::string errmsg{"subject2name error: cannot add "};
                    errmsg += "/" + type + "=" + subject.substr(prev, len) + "\n";
                    ERR_print_errors_cb(print_error, &errmsg);
                    throw std::runtime_error(errmsg);
                }
            }
            chr = '=';
        }
        prev = i + 1;
    }

    return name;
}

void selfsigned(const EVP_PKEY_ptr& pkey,
                const int days,
                const std::string& subject,
                const std::string& crtpath,
                const bool use_pem)
{
    auto* x509 = X509_new();

    if (x509 == nullptr) {
        std::string errmsg{"selfsigned error: cannot create X509 structure\n"};
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg);
    }

    auto freeX509_and_throw = [&x509](const std::string& what) {
        X509_free(x509);
        std::string errmsg{"selfsigned error: cannot set "};
        errmsg += what + " in X509 certificate\n";
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg);
    };

    if (X509_set_version(x509, 2) == 0) {
        freeX509_and_throw("version");
    }

    if (X509_set_pubkey(x509, pkey.get()) == 0) {
        freeX509_and_throw("pubkey");
    }

    if ((X509_gmtime_adj(X509_getm_notBefore(x509), 0) == nullptr) ||
        (X509_time_adj_ex(X509_getm_notAfter(x509), days, 0, nullptr) == nullptr))
    {
        freeX509_and_throw("times");
    }

    X509_NAME_ptr name{nullptr, ::X509_NAME_free};

    try {
        name = subject2name(subject);
    }
    catch (...) {
        X509_free(x509);
        throw;
    }

    if (X509_set_subject_name(x509, name.get()) == 0) {
        freeX509_and_throw("subject");
    }

    if (X509_set_issuer_name(x509, name.get()) == 0) {
        freeX509_and_throw("issuer");
    }

    auto* bignum = BN_new();

    if (bignum == nullptr) {
        freeX509_and_throw("serial (creating big number struct)");
    }

    static const auto BITS = 159;
    if (BN_rand(bignum, BITS, BN_RAND_TOP_ANY, BN_RAND_BOTTOM_ANY) == 0) {
        BN_free(bignum);
        freeX509_and_throw("serial (creating random number)");
    }

    if (BN_to_ASN1_INTEGER(bignum, X509_get_serialNumber(x509)) == nullptr) {
        BN_free(bignum);
        freeX509_and_throw("random serial");
    }

    BN_free(bignum);

    if (X509_sign(x509, pkey.get(), EVP_sha256()) == 0) {
        freeX509_and_throw("signing digest");
    }

    BIO* bio = crtpath.empty() ? _BIO_new_fp(stdout, use_pem)
                               : BIO_new_file(crtpath.c_str(), (use_pem ? "w" : "wb"));

    int len = 0;

    if (bio != nullptr) {
        len = use_pem ? PEM_write_bio_X509(bio, x509) : i2d_X509_bio(bio, x509);
        BIO_free_all(bio);
    }

    X509_free(x509);

    if (len == 0) {
        std::string errmsg{"selfsigned error: cannot write certificate to "};
        errmsg += crtpath.empty() ? "stdout" : crtpath;
        errmsg += "\n";
        ERR_print_errors_cb(print_error, &errmsg);
        throw std::runtime_error(errmsg);
    }
}

#endif
