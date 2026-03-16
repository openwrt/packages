#!/bin/sh


sed -i "s|update_dnsmasq_config|dnsmasq_config_update|" "/etc/config/https-dns-proxy"
sed -i "s|wan6_trigger|procd_trigger_wan6|" "/etc/config/https-dns-proxy"
sed -i "s|procd_fw_src_interfaces|force_dns_src_interface|" "/etc/config/https-dns-proxy"
sed -i "s|use_http1|force_http1|" "/etc/config/https-dns-proxy"
sed -i "s|use_ipv6_resolvers_only|force_ipv6_resolvers|" "/etc/config/https-dns-proxy"
