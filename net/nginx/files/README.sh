#!/bin/sh
# This is a template copy it by: ./README.sh | xclip -selection c
# to https://openwrt.org/docs/guide-user/services/webserver/nginx#configuration

source ./nginx.init.ssl

EXAMPLE_COM="example.com"

PREFIX_EXAMPLE_COM="conf.d/${EXAMPLE_COM}"

MSG="
/* Created by the following bash script that includes the source of some files:
 * https://github.com/openwrt/packages/net/nginx/files/README.sh
 */"

code() { printf "<file nginx %s>\n%s</file>" "$1" "$(cat "$(basename $1)")"; }

ifConfEcho() { sed -nE "s/^\s*$1=\s*(\S*)\s*\\\\$/\n$2 \"\1\";/p" ../Makefile;}

cat <<EOF





===== Configuration =====${MSG}



The official Documentation contains a
[[https://docs.nginx.com/nginx/admin-guide/|Admin Guide]].
Here we will look at some often used configuration parts and how we handle them
at OpenWrt.
At different places there are references to the official
[[https://docs.nginx.com/nginx/technical-specs/|Technical Specs]]
for further reading.



==== Basic ====${MSG}


We modify the configuration by creating different configuration files in the
''/etc/nginx/conf.d/''
directory.
The configuration files use the file extensions ''.locations'' and
''.conf'' (plus ''.crt'' and ''.key'' for Nginx with SSL).
We can disable single configuration parts by giving them another extension,
e.g., by adding ''.disabled''.
For the new configuration to take effect, we must reload it by:
<code>service nginx reload</code>

For OpenWrt we use a special initial configuration, which is explained below in
the section [[#openwrt_s_defaults|OpenWrt’s Defaults]].
So, we can make a site available at a specific URL in the **LAN** by creating a
''.locations'' file in the directory ''/etc/nginx/conf.d/''.
Such a file consists just of some
[[https://nginx.org/en/docs/http/ngx_http_core_module.html#location|
location blocks]].
Under the latter link, you can find also the official documentation for all
available directives of the HTTP core of Nginx.
Look for //location// in the Context list.

The following example provides a simple template, see at the end in the
different [[#locations_for_apps|Locations for Apps]] and look for
[[https://github.com/search?utf8=%E2%9C%93&q=repo%3Aopenwrt%2Fpackages
+extension%3Alocations&type=Code&ref=advsearch&l=&l=|
other packages using a .locations file]], too:
<code nginx /etc/nginx/conf.d/example.locations>
location /ex/am/ple {
    access_log off; # default: not logging accesses.
    # access_log /proc/self/fd/1 openwrt; # enable logd (init forwards stdout).
    # error_log stderr; # default: logging to logd (init forwards stderr).
    error_log /dev/null; # disable error logging after config file is read.
    # (state the path of a file for access_log/error_log to the file instead.)
    index index.html;
}
# location /eg/static { … }
</code>

All location blocks in all ''.locations'' files must use different URLs,
since they are all included in the ''${NAME}.conf'' that is part of the
[[#openwrt_s_defaults|OpenWrt’s Defaults]].
We reserve the ''location /'' for making LuCI available under the root URL,
e.g. [[http://192.168.1.1/|192.168.1.1/]].
All other sites shouldn’t use the root ''location /'' without suffix.
We can make other sites available on the root URL of other domain names, e.g.
on www.example.com/.
In order to do that, we create a ''.conf'' file for every domain name:
see the next section [[#new_server_parts|New Server Parts]].
For Nginx with SSL we can also activate SSL there, as described below in the
section [[#ssl_server_parts|SSL Server Parts]].
We use such server parts also for publishing sites to the internet (WAN)
instead of making them available just in the LAN.

Via ''.conf'' files we can also add directives to the http part of the
configuration. The difference to editing the main ''/etc/nginx/nginx.conf''
file instead is the following: If the package’s ''nginx.conf'' file is updated
it will only be installed if the old file has not been changed.



==== New Server Parts ====${MSG}


For making the router reachable from the WAN at a registered domain name,
it is not enough to give the name server the internet IP address of the router
(maybe updated automatically by a
[[docs:guide-user:services:ddns:client|DDNS Client]]).
We also need to set up virtual hosting for this domain name by creating an
appropriate server part in a ''/etc/nginx/conf.d/*.conf'' file.
All such files are included at the start of Nginx by the default main
configuration of OpenWrt ''/etc/nginx/nginx.conf'' as depicted in
[[#openwrt_s_defaults|OpenWrt’s Defaults]].

In the server part, we state the domain as
[[https://nginx.org/en/docs/http/ngx_http_core_module.html#server_name|
server_name]].
The link points to the same document as for the location blocks in the
[[#basic|Basic Configuration]]: the official documentation for all available
directives of the HTTP core of Nginx.
This time look for //server// in the Context list, too.
The server part should also contain similar location blocks as before.
We can re-include a ''.locations'' file that is included in the server part for
the LAN by default.
Then the site is reachable under the same path at both domains, e.g., by
http://192.168.1.1/ex/am/ple as well as by http://example.com/ex/am/ple.

The [[#openwrt_s_defaults|OpenWrt’s Defaults]] include a ''${NAME}.conf''
file containing a server part that listens on the LAN address(es) and acts as
//default_server//.
For making the domain name accessible in the LAN, too, the corresponding
server part must listen **explicitly** on the local IP address(es), cf. the
official documentation on
[[https://nginx.org/en/docs/http/request_processing.html|request_processing]].
We can include the file ''${LAN_LISTEN}'' that contains the listen
directives for all LAN addresses on the HTTP port 80 and is automatically
updated.

The following example is a simple template, see
[[https://github.com/search?q=repo%3Aopenwrt%2Fpackages
+include+${LAN_LISTEN}+extension%3Aconf&type=Code|
such server parts of other packages]], too:
<code nginx ${PREFIX_EXAMPLE_COM}.conf>
server {
    listen 80;
    listen [::]:80;
    include '${LAN_LISTEN}';
    server_name ${EXAMPLE_COM};
    # location / { … } # root location for this server.
    include '${PREFIX_EXAMPLE_COM}.locations';
}
</code>



==== SSL Server Parts ====${MSG}


We can enable HTTPS for a domain if Nginx is installed with SSL support.
We need a SSL certificate as well as its key and add them by the directives
//ssl_certificate// respective //ssl_certificate_key// to the server part of the
domain.
The rest of the configuration is similar as described in the previous section
[[#new_server_parts|New Server Parts]],
we only have to adjust the listen directives by adding the //ssl// parameter,
see the official documentation for
[[https://nginx.org/en/docs/http/configuring_https_servers.html|
configuring HTTPS servers]], too.
For making the domain available also in the LAN, we can include the file
''${LAN_SSL_LISTEN}'' that contains the listen directives with ssl
parameter for all LAN addresses on the HTTPS port 443 and is automatically
updated.

The official documentation of the SSL module contains an
[[https://nginx.org/en/docs/http/ngx_http_ssl_module.html#example|
example]],
which includes some optimizations.
The following template is extended similarly, see also
[[https://github.com/search?q=repo%3Aopenwrt%2Fpackages
+include+${LAN_SSL_LISTEN}+extension%3Aconf&type=Code|
other packages providing SSL server parts]]:
<code nginx /etc/nginx/${PREFIX_EXAMPLE_COM}>
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    include '${LAN_SSL_LISTEN}';
    server_name ${EXAMPLE_COM};
    $(_echo_sed "$(_sed_rhs "${NGX_SSL_CRT}" "${PREFIX_EXAMPLE_COM}")")
    $(_echo_sed "$(_sed_rhs "${NGX_SSL_KEY}" "${PREFIX_EXAMPLE_COM}")")
    $(_echo_sed "$(_sed_rhs "${NGX_SSL_SESSION_CACHE}" "${EXAMPLE_COM}")")
    $(_echo_sed "$(_sed_rhs "${NGX_SSL_SESSION_TIMEOUT}" "")")
    # location / { … } # root location for this server.
    include '${PREFIX_EXAMPLE_COM}.locations';
}
</code>

For creating a certificate (and its key) we can use Let’s Encrypt by installing
[[https://github.com/Neilpang/acme.sh|ACME Shell Script]]:
<code>opkg update && opkg install acme # and for LuCI: luci-app-acme</code>

For the LAN server in the ''${NAME}.conf'' file, the init script
''/etc/init.d/nginx'' script installs automatically a self-signed certificate.
We can use this mechanism also for other sites by issuing, e.g.:
<code>service nginx ${ADD_SSL_FCT} ${EXAMPLE_COM}</code>
  - This checks if there is a valid certificate and key for the given domain \
  name or tries to create a self-signed one if possible. We can install a tool\
  by: <code>opkg update && opkg install openssl-util</code>
  - Then it adds SSL directives to the server part of \
  ''${PREFIX_EXAMPLE_COM}.conf'' like in the example above.
  - When cron is activated, it installs a cron job for renewing the \
  certificate every year if needed, too. We can activate cron by: \
  <code>service cron enable && service cron start</code>

Beside the ''${NAME}.conf'' file, the
[[#openwrt_s_defaults|OpenWrt’s Defaults]] include also the
''_redirect2ssl.conf'' file containing a server part that redirects all HTTP
request for inexistent URIs to HTTPS.



==== OpenWrt’s Defaults ====${MSG}


The default main configuration file is:
$(code /etc/nginx/nginx.conf)

We can pretend the main configuration contains also the following presets,
since Nginx is configured with them:
<code nginx>$(ifConfEcho --pid-path pid)\
$(ifConfEcho --lock-path lock_file)\
$(ifConfEcho --error-log-path error_log)\
$(false && ifConfEcho --http-log-path access_log)\
$(ifConfEcho --http-proxy-temp-path proxy_temp_path)\
$(ifConfEcho --http-client-body-temp-path client_body_temp_path)\
$(ifConfEcho --http-fastcgi-temp-path fastcgi_temp_path)\
</code>

So, the access log is turned off by default and we can look at the error log
by ''logread'', as Nginx’s init file forwards stderr and stdout to the
[[docs:guide-user:base-system:log.essentials|logd]].
We can set the //error_log// and //access_log// to files where the log
messages are forwarded to instead (after the configuration is read).
And for redirecting the access log of a //server// or //location// to the logd,
too, we insert the following directive in the corresponding block:
<code nginx>
    access_log /proc/self/fd/1 openwrt;
</code>

At the end, the main configuration pulls in all ''.conf'' files from the
directory ''/etc/nginx/conf.d/'' into the http block, especially the following
server part for the LAN:
$(code ${PREFIX}.conf)

It pulls in all ''.locations'' files from the directory ''/etc/nginx/conf.d/''.
We can install the location parts of different sites there (see above in the
[[#basic|Basic Configuration]]) and re-include them in server parts  of other
''/etc/nginx/conf.d/*.conf'' files.
This is needed especially for making them available to the WAN as described
above in the section [[#new_server_parts|New Server Parts]].
All ''.locations'' become available on the LAN through the file
''lan.listen.default'', which contains one of the following directives for
every local IP address:
<code nginx>
         listen IPv4:80 default_server;
         listen [IPv6]:80 default_server;
</code>
The ''${LAN_LISTEN}'' file contains the same directives without the
parameter ''default_server''.
We can include this file in other server parts that should be reachable in the
LAN through their //server_name//.
Both files ''${LAN_LISTEN}{,.default}'' are (re-)created if Nginx starts
through its init for OpenWrt or the LAN interface changes.

=== Additional Defaults for OpenWrt if Nginx is installed with SSL support ===

When Nginx is installed with SSL support, there will be automatically managed
files ''lan_ssl.listen.default'' and ''lan_ssl.listen'' in the directory
''/var/lib/nginx/'' containing the following directives for all IPv4 and IPv6
addresses of the LAN:
<code nginx>
         listen IP:443 ssl; # with respectively without: default_server
</code>
Both files as well as the ''${LAN_LISTEN}{,.default}'' files are (re-)created
if Nginx starts through its init for OpenWrt or the LAN interface changes.

For Nginx with SSL there is also the following server part that redirects
requests for an inexistent ''server_name'' from HTTP to HTTPS (using an invalid
name, more in the official documentation on
[[https://nginx.org/en/docs/http/request_processing.html|request_processing]]):
$(code /etc/nginx/conf.d/_redirect2ssl.conf)

Nginx’s init file for OpenWrt installs automatically a self-signed certificate
for the LAN server part if needed and possible:
    - Everytime Nginx starts, we check if the LAN has already a valid ssl \
    certificate and key in ''${PREFIX}.{crt,key}''
    - If there is no valid certificate, we try to create a self-signed one. \
    That needs ''px5g'' or ''openssl-util'' to be installed, though.
    - When there exists a certificate, we add corresponding //ssl*// \
    directives (like in the example of the previous section \
    [[#ssl_server_parts|SSL Server Parts]]) to the configuration file \
    ''${PREFIX}.conf'' if needed and if it looks “normal”, i.e., it has a \
    ''server_name ${NAME};'' part.
    - When there is a valid certificate for the LAN, we activate ssl by \
    including the ssl listen directives from ''${LAN_SSL_LISTEN}.default'' and\
    it becomes available by the default redirect from ''listen *:80;'' in \
    ''/etc/nginx/conf.d/_redirect2ssl.conf''
    - If cron is available, i.e., its status is not ''inactive'', we use it \
    to check the certificate for validity once a year and renew it if there \
    are only 13 months of the more than 3 years life time left.

The points 2, 3 and 5 can be used for other domains, too:
As described in the section [[#new_server_parts|New Server Parts]] above, we
create a server part in ''/etc/nginx/conf.d/www.example.com.conf'' with
a corresponding ''server_name www.example.com;'' directive and call
<code>/etc/init.d/nginx ${ADD_SSL_FCT} www.example.com</code>
EOF
