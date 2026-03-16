![ApFreeWiFiDog](https://github.com/liudf0716/apfree_wifidog/blob/master/logo.png)


[![license][1]][2]
[![PRs Welcome][3]][4]
[![Issues Welcome][5]][6]
[![Release Version][7]][8]
[![OpenWrt][11]][12]
[![Join the QQ Group][15]][16]


[1]: https://img.shields.io/badge/license-GPLV3-brightgreen.svg?style=plastic
[2]: https://github.com/liudf0716/apfree_wifidog/blob/master/COPYING
[3]: https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=plastic
[4]: https://github.com/liudf0716/apfree_wifidog/pulls
[5]: https://img.shields.io/badge/Issues-welcome-brightgreen.svg?style=plastic
[6]: https://github.com/liudf0716/apfree_wifidog/issues/new
[7]: https://img.shields.io/badge/release-3.11.1716-red.svg?style=plastic
[8]: https://github.com/liudf0716/apfree_wifidog/releases
[11]: https://img.shields.io/badge/Platform-%20OpenWrt%7C%20LEDE%20-brightgreen.svg?style=plastic
[12]: https://github.com/KunTengRom/kunteng-lede-17.01.4
[13]: https://img.shields.io/badge/KunTeng-Inside-blue.svg?style=plastic
[14]: https://www.kunteng.org.cn
[15]: https://img.shields.io/badge/chat-qq%20group-brightgreen.svg
[16]: https://jq.qq.com/?_wv=1027&k=4ADDSev

## ApFree WiFiDog: A high performance captive portal solution for HTTP(s)

ApFree WiFiDog is a high performance captive portal solution for HTTP(s), which mainly used in ([LEDE](https://github.com/lede-project/source) & [OpenWrt](https://github.com/openwrt/openwrt)) platform. 


**[中文介绍](https://github.com/liudf0716/apfree_wifidog/blob/master/README_ZH.md)**

## Enhancement of apfree-wifidog 

In fact, the title should be why we choose apfree-wifidog, the reason was the following: 

>  Stable

apfree-wifidog was widely used in tens of thousands device, which were running in business scene. In order to improve its stable, we rewrite all iptables rule by api instead of fork call, which will easily cause deadlock in multithread-fork running environment. we also re-write the code and replace libhttpd (which is unmaintained for years) with libevent

> Performance

apfree-wifidog's http request-response is more quick, u can find statistic data in our test document

> HTTPs redirect

apfree-wifidog support https redirect, in current internet environment, captive portal solution without supporting https redirect will become unsuitable gradually


> More features

apfree-wifidog support mac temporary-pass, ip,domain,pan-domain,white-mac,black-mac rule and etc. all these rules can be applied without restarting wifidog

> MQTT support

by enable mqtt support, u can remotely deliver such as trusted ip, domain and pan-domain rules to apfree wifidog 

> Compilable with wifidog protocol

u don't need to modify your wifidog authentication server to adapt apfree-wifidog; if u have pression on server-side, apfree wifidog's improved protocol can greatly relieve it, which disabled by default


## Getting started

before starting apfree-wifidog, we must know how to configure it. apfree-wifidog use OpenWrt standard uci config system, all your apfree-wifidog configure information stored in `/etc/confg/wifidogx`, which will be parsed by  `/etc/init.d/wifidogx` to /tmp/wifidog.conf, apfree-wifidog's real configure file is `/tmp/wifidog.conf`

The default apfree-wifidog UCI configuration file like this:

```
config wifidog
    option  gateway_interface   'br-lan'
    option  auth_server_hostname    'wifidog.kunteng.org.cn'
    option  auth_server_port    443
    option  auth_server_path    '/wifidog/'
    option  check_interval      60
    option  client_timeout      5
    option  apple_cna           1
    option  thread_number       5
    option  wired_passed        0
    option  enable      0
```

> auth_server_hostname was apfree-wifidog auth server, it can be domain or ip; wifidog.kunteng.org.cn is a free auth server we provided, it was also [open source](https://github.com/wificoin-project/wwas) 

> apple_cna 1 apple captive detect deceive; 2 apple captive detect deceive to  disallow portal page appear

> wired_passed means whether LAN access devices need to auth or not, value 1 means no need to auth 

> enable means whether start apfree-wifidog when we executed `/etc/init.d/wifidogx start`, if u wanted to start apfree-wifidog, you must set enable to 1 before executing `/etc/init.d/wifidogx start`

### How to support https redirect

In order to support https redirect, apfree-wifidog need x509 pem cert and private key, u can generate yourself like this:

```
PX5G_BIN="/usr/sbin/px5g"
OPENSSL_BIN="/usr/bin/openssl"
APFREE_CERT="/etc/apfree.crt"
APFREE_KEY="/etc/apfree.key"

generate_keys() {
    local days bits country state location commonname

    # Prefer px5g for certificate generation (existence evaluated last)
    local GENKEY_CMD=""
    local UNIQUEID=$(dd if=/dev/urandom bs=1 count=4 | hexdump -e '1/1 "%02x"')
    [ -x "$OPENSSL_BIN" ] && GENKEY_CMD="$OPENSSL_BIN req -x509 -sha256 -outform pem -nodes"
    [ -x "$PX5G_BIN" ] && GENKEY_CMD="$PX5G_BIN selfsigned -pem"
    [ -n "$GENKEY_CMD" ] && {
        $GENKEY_CMD \
            -days ${days:-730} -newkey rsa:${bits:-2048} -keyout "${APFREE_KEY}.new" -out "${APFREE_CERT}.new" \
            -subj /C="${country:-CN}"/ST="${state:-localhost}"/L="${location:-Unknown}"/O="${commonname:-ApFreeWiFidog}$UNIQUEID"/CN="${commonname:-ApFreeWiFidog}"
        sync
        mv "${APFREE_KEY}.new" "${APFREE_KEY}"
        mv "${APFREE_CERT}.new" "${APFREE_CERT}"
    }
}

```

or when u start `/etc/init.d/wifidogx start`, it will generate it automatically


For more information, please refer to the upstream [project page](https://github.com/liudf0716/apfree_wifidog)
