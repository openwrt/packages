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

PRINT_PASSED="true"
    
function test() {
    MSG="$1 >/dev/null \t (-> $2?) \t"
    eval "$1 >/dev/null "
    if [ $? -eq $2 ] 
    then
        [ "$PRINT_PASSED" == "true" ] && printf "$MSG passed.\n"
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

test 'cat "$OPENSSL_PEM" | openssl x509 -checkend 0 -inform der 2>/dev/null ' 1
test 'cat "$OPENSSL_DER" | openssl x509 -checkend 0             2>/dev/null ' 1

test 'cat "$OPENSSL_PEM" | ./px5g checkend 0                                ' 0
test 'cat "$OPENSSL_PEM" | ./px5g checkend 86399                            ' 0
test 'cat "$OPENSSL_PEM" | ./px5g checkend 86400                            ' 1

test 'cat "$OPENSSL_DER" | ./px5g checkend 0 -der                           ' 0
test 'cat "$OPENSSL_DER" | ./px5g checkend 86300 -der                       ' 0
test 'cat "$OPENSSL_DER" | ./px5g checkend 86400 -der                       ' 1
test 'cat "$OPENSSL_DER" | ./px5g checkend 0 -der -in -                     ' 0
test 'cat "$OPENSSL_DER" | ./px5g checkend 86300 -in - -der                 ' 0
test 'cat "$OPENSSL_DER" | ./px5g checkend 86400 -der -in -                 ' 1

test 'cat "$OPENSSL_PEM" | ./px5g checkend 0 -der               2>/dev/null ' 1
test 'cat "$OPENSSL_DER" | ./px5g checkend 0                    2>/dev/null ' 1


rm "$OPENSSL_PEM" "$OPENSSL_DER"
