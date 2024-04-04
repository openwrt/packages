#!/bin/sh

curr_ver=0.4.7

# Copyright: antonk (antonk.d3v@gmail.com)
# github.com/friendly-bits

ipv4_regex='((25[0-5]|(2[0-4]|1[0-9]|[1-9]|)[0-9])\.){3}(25[0-5]|(2[0-4]|1[0-9]|[1-9]|)[0-9])'
ipv6_regex='([0-9a-f]{0,4})(:[0-9a-f]{0,4}){2,7}'
maskbits_regex_ipv4='(3[0-2]|([1-2][0-9])|[6-9])'
maskbits_regex_ipv6='(12[0-8]|((1[0-1]|[1-9])[0-9])|[6-9])'
subnet_regex_ipv4="${ipv4_regex}\/${maskbits_regex_ipv4}"
subnet_regex_ipv6="${ipv6_regex}\/${maskbits_regex_ipv6}"
