#! /bin/sh

set -o errexit

test_url() {
    echo "INFO: Testing '${2}' has ${1} addresses" >&2

    case "${1}" in
        IPv4)
            nslookup -type=a "${2}"
            ;;
        IPv6)
            nslookup -type=aaaa "${2}"
            ;;
        *)
            echo "ERROR: Unknown IP version: ${1}" >&2
            exit 1
            ;;
    esac
}

cache_domains() {
    echo "INFO: cache-domains ${1}" >&2
    cache-domains "${1}"
    sleep 5
}

cache_domains cleanup

test_url IPv4 lancache.steamcontent.com | grep -q 'canonical name ='
test_url IPv6 lancache.steamcontent.com | grep -q 'canonical name ='

test_url IPv4 dist.blizzard.com | grep -q 'canonical name ='
test_url IPv6 dist.blizzard.com | grep -q 'canonical name ='

cache_domains configure

test_url IPv4 lancache.steamcontent.com | grep -q '10.10.3.10'
test_url IPv4 lancache.steamcontent.com | grep -q '10.10.3.11'
test_url IPv6 lancache.steamcontent.com > /dev/null # None configured

test_url IPv4 dist.blizzard.com | grep -q '10.10.3.13'
test_url IPv6 dist.blizzard.com > /dev/null # None configured

cache_domains cleanup

test_url IPv4 lancache.steamcontent.com | grep -q 'canonical name ='
test_url IPv6 lancache.steamcontent.com | grep -q 'canonical name ='

test_url IPv4 dist.blizzard.com | grep -q 'canonical name ='
test_url IPv6 dist.blizzard.com | grep -q 'canonical name ='
