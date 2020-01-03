#!/bin/sh

OPENSSL_PEM="$(mktemp)"
OPENSSL_DER="$(mktemp)"

NONCE=$(dd if=/dev/urandom bs=1 count=4 2>/dev/null | hexdump -e '1/1 "%02x"')
openssl req -x509 -nodes -days 1 -keyout /dev/null 2>/dev/null \
    -out "$OPENSSL_PEM" \
    -subj /C="ZZ"/ST="Somewhere"/L="None"/O="OpenWrt'$NONCE'"/CN="OpenWrt" \
|| ( echo "error: generating PEM certificate with openssl"; return 1)
openssl req -x509 -nodes -days 1 -keyout /dev/null 2>/dev/null \
    -out "$OPENSSL_DER" -outform der \
    -subj /C="ZZ"/ST="Somewhere"/L="None"/O="OpenWrt'$NONCE'"/CN="OpenWrt" \
|| ( echo "error: generating DER certificate with openssl"; return 1)

PRINT_PASSED=0
    
function test() {
    MSG="$1 >/dev/null \t (-> $2?) \t"
    eval "$1 >/dev/null "
    if [ $? -eq $2 ] 
    then
        [ "$PRINT_PASSED" -gt 0 ] && printf "$MSG passed.\n"
    else 
        printf "$MSG failed!!!\n"
    fi
}

test 'cat "$OPENSSL_PEM" | openssl x509 -checkend 0                         ' 0
test 'cat "$OPENSSL_PEM" | openssl x509 -checkend 86300                     ' 0
test 'cat "$OPENSSL_PEM" | openssl x509 -checkend 86400                     ' 1

test 'cat "$OPENSSL_DER" | openssl x509 -checkend 0    -inform der          ' 0
test 'cat "$OPENSSL_DER" | openssl x509 -checkend 86300 -inform der         ' 0
test 'cat "$OPENSSL_DER" | openssl x509 -checkend 86400 -inform der         ' 1

test 'cat "$OPENSSL_PEM" | openssl x509 -checkend 0 -inform der  2>/dev/null' 1
test 'cat "$OPENSSL_DER" | openssl x509 -checkend 0              2>/dev/null' 1

test 'cat "$OPENSSL_PEM" | ./px5g checkend 0                                ' 0
test 'cat "$OPENSSL_PEM" | ./px5g checkend 86300                            ' 0
test 'cat "$OPENSSL_PEM" | ./px5g checkend 86400                            ' 1

test 'cat "$OPENSSL_DER" | ./px5g checkend -der 0                           ' 0
test 'cat "$OPENSSL_DER" | ./px5g checkend -der 86300                       ' 0
test 'cat "$OPENSSL_DER" | ./px5g checkend -der 86400                       ' 1
test 'cat "$OPENSSL_DER" | ./px5g checkend -der -in - 0                     ' 0
test 'cat "$OPENSSL_DER" | ./px5g checkend -in - -der 86300                 ' 0
test 'cat "$OPENSSL_DER" | ./px5g checkend -der -in - 86400                 ' 1

test 'cat "$OPENSSL_PEM" | ./px5g checkend -der 0                2>/dev/null' 1
test 'cat "$OPENSSL_DER" | ./px5g checkend 0                     2>/dev/null' 1

test './px5g eckey -der -out -  | openssl ec -check -inform der  2>/dev/null' 0
test './px5g eckey -out -       | openssl ec -check              2>/dev/null' 0
test './px5g eckey P-256        | openssl ec -check              2>/dev/null' 0
test './px5g eckey P-384        | openssl ec -check              2>/dev/null' 0
test './px5g eckey P-521        | openssl ec -check              2>/dev/null' 0
test './px5g eckey secp521r1    | openssl ec -check              2>/dev/null' 0
test './px5g eckey secp384r1    | openssl ec -check              2>/dev/null' 0
test './px5g eckey secp256r1    | openssl ec -check              2>/dev/null' 0
test './px5g eckey secp256k1    | openssl ec -check              2>/dev/null' 0
test './px5g eckey secp224r1    | openssl ec -check              2>/dev/null' 0
test './px5g eckey secp224k1    | openssl ec -check              2>/dev/null' 0
test './px5g eckey secp192r1    | openssl ec -check              2>/dev/null' 0
test './px5g eckey secp192k1    | openssl ec -check              2>/dev/null' 0
test './px5g eckey brainpoolP512r1 | openssl ec -check           2>/dev/null' 0
test './px5g eckey brainpoolP384r1 | openssl ec -check           2>/dev/null' 0
test './px5g eckey brainpoolP256r1 | openssl ec -check           2>/dev/null' 0

test './px5g rsakey -der -out - | openssl rsa -check -inform der 2>/dev/null' 0
test './px5g rsakey -out -      | openssl rsa -check             2>/dev/null' 0
test './px5g rsakey             | openssl rsa -check             2>/dev/null' 0
test './px5g rsakey 512         | openssl rsa -check             2>/dev/null' 0
test './px5g rsakey 1024        | openssl rsa -check             2>/dev/null' 0
test './px5g rsakey 2048        | openssl rsa -check             2>/dev/null' 0
test './px5g rsakey 4096        | openssl rsa -check             2>/dev/null' 0
test './px5g rsakey 5000        | openssl rsa -check             2>/dev/null' 0
test './px5g rsakey 0                                            2>/dev/null' 1
test './px5g rsakey -3          | openssl rsa -check             2>/dev/null' 0
test './px5g rsakey -3 512      | openssl rsa -check             2>/dev/null' 0
test './px5g rsakey -3 1024     | openssl rsa -check             2>/dev/null' 0
test './px5g rsakey -3 2048     | openssl rsa -check             2>/dev/null' 0
test './px5g rsakey -3 4096     | openssl rsa -check             2>/dev/null' 0
test './px5g rsakey -3 5000     | openssl rsa -check             2>/dev/null' 0
test './px5g rsakey -3 0                                         2>/dev/null' 1

# ./px5g -der -newkey rsa:1024 -days 1 -keyout /dev/null -out - -subj
# ./px5g -der -newkey ec -days 1 -pkeyopt ec_paramgen_curve:name -keyout /dev/null -out - -subj


rm "$OPENSSL_PEM" "$OPENSSL_DER"
