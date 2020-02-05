#!/bin/sh
#Copyright 2019 Nixon Li <609169788@qq.com>
#Copyright 2020 Kongou Hikari <hikari@iloli.bid>
#检查传入参数
[ -z "$username" ] && write_log 14 "Configuration error, 'username' can't be empty"
[ -z "$password" ] && write_log 14 "Configuration error, 'password' can't be empty"

#检查外部工具curl,sed
command -v curl >/dev/null 2>&1 || write_log 13 "Please install curl first"
command -v sed >/dev/null 2>&1 || write_log 13 "Please install sed first"

# 变量声明
local __HOST __DOMAIN __TYPE __RECIP __RECID DATFILE

# 从 $domain 分离主机和域名
[ "${domain:0:2}" == "@." ] && domain="${domain/./}" # 主域名处理
[ "$domain" == "${domain/@/}" ] && domain="${domain/./@}" # 未找到分隔符，兼容常用域名格式
__HOST="${domain%%@*}"
__DOMAIN="${domain#*@}"
[ -z "$__HOST" -o "$__HOST" == "$__DOMAIN" ] && __HOST="@"

# 设置记录类型
[ $use_ipv6 -eq 0 ] && __TYPE="A" || __TYPE="AAAA"

#添加解析记录
add_domain() {
DATFILE=`curl -s -d "login_token=$username,$password&format=json&domain=$__DOMAIN&sub_domain=$__HOST&record_type=$__TYPE&record_line_id=0&value=${__IP}&ttl=120" "https://dnsapi.cn/Record.Create"`
value=`jsonfilter -s "$DATFILE" -e "@.status.code"`
if [ $value == 1 ];then
        write_log 7 "Add new record for IP:[$__HOST],[$__TYPE],[${__IP}] successful!"
else
        write_log 14 "Add new record for IP:[$__HOST],[$__TYPE],[${__IP}] failed! return:$value"
fi
}

#修改解析记录
update_domain() {
DATFILE=`curl -s -d "login_token=$username,$password&format=json&domain=$__DOMAIN&record_id=$__RECID&value=${__IP}&record_type=$__TYPE&record_line_id=0&sub_domain=$__HOST" "https://dnsapi.cn/Record.Ddns"`
value=`jsonfilter -s "$DATFILE" -e "@.status.code"`
if [ $value == 1 ];then
        write_log 7 "Modify record :[$__HOST],type:[$__TYPE],ip:[${__IP}] successful!"
else
        write_log 14 "Modify record:[$__HOST],type:[$__TYPE],ip:[${__IP}]failed! return:$value"
fi
}

#获取域名解析记录
describe_domain() {
        DATFILE=`curl -s -d "login_token=$username,$password&format=json&domain=$__DOMAIN" "https://dnsapi.cn/Record.List"`
        value=`jsonfilter -s "$DATFILE" -e "@.records[@.name='$__HOST'].name"`
        if [ "$value" == "" ]; then
                write_log 7 "Record:[$__HOST] doesn't exist, category: HOST"
                ret=1
        else
                value=`jsonfilter -s "$DATFILE" -e "@.records[@.name='$__HOST'].type"`
                if [ "$value" != "$__TYPE" ]; then
                                write_log 7 "Current record type doesn't match:[$__TYPE],"
                                ret=2; continue
                else
                        __RECID=`jsonfilter -s "$DATFILE" -e "@.records[@.name='$__HOST'].id"`
                        write_log 7 "Acquired record ID:[$__RECID], type: ID"
                        __RECIP=`jsonfilter -s "$DATFILE" -e "@.records[@.name='$__HOST'].value"`
                        if [ "$__RECIP" != "${__IP}" ]; then
                                write_log 7 "Address needs to be update:[${__IP}]"
                                ret=2
                        fi
                fi
        fi
        return $ret
}
describe_domain
ret=$?
if [ $ret == 1 ];then
        sleep 3 && add_domain
elif [ $ret == 2 ];then
        sleep 3 && update_domain
else
        write_log 7 "local IP：“${__IP}” Record IP：“$__RECIP” not necessary to change"
fi

return 0

