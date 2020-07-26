#!/bin/sh
# This is a template copy it by: ./README.sh | xclip -selection c
# to https://openwrt.org/docs/guide-user/services/webserver/nginx#configuration

NGINX_UTIL="/usr/bin/nginx-util"

EXAMPLE_COM="example.com"

MSG="
/* Created by the following bash script that includes the source of some files:
 * https://github.com/openwrt/packages/net/nginx/files/README.sh
 */"

eval $("${NGINX_UTIL}" get_env)

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

**tl;dr:** The main configuration is a minimal configuration enabling the
''${CONF_DIR}'' directory:
  * There is a ''${LAN_NAME}.conf'' containing a default server for the LAN, \
which includes all ''*.locations''.
  * We can disable parts of the configuration by renaming them.
  * If we want to install other HTTPS servers that are also reachable locally, \
  we can include the ''${LAN_SSL_LISTEN}'' file.
  * We have a server in ''_redirect2ssl.conf'' that redirects inexistent URLs \
  to HTTPS, too.
  * We can create a self-signed certificate and add corresponding directives \
to e.g. ''${EXAMPLE_COM}.conf'' by invoking \
<code>$(basename ${NGINX_UTIL}) ${ADD_SSL_FCT} ${EXAMPLE_COM}</code>



==== Basic ====${MSG}


We modify the configuration by creating different configuration files in the
''${CONF_DIR}'' directory.
The configuration files use the file extensions ''.locations'' and
''.conf'' plus ''.crt'' and ''.key'' for SSL certificates and keys.
We can disable single configuration parts by giving them another extension,
e.g., by adding ''.disabled''.
For the new configuration to take effect, we must reload it by:
<code>service nginx reload</code>

For OpenWrt we use a special initial configuration, which is explained below in
the section [[#openwrt_s_defaults|OpenWrt’s Defaults]].
So, we can make a site available at a specific URL in the **LAN** by creating a
''.locations'' file in the directory ''${CONF_DIR}''.
Such a file consists just of some
[[https://nginx.org/en/docs/http/ngx_http_core_module.html#location|
location blocks]].
Under the latter link, you can find also the official documentation for all
available directives of the HTTP core of Nginx.
Look for //location// in the Context list.

The following example provides a simple template, see at the end for
different [[#locations_for_apps|Locations for Apps]] and look for
[[https://github.com/search?utf8=%E2%9C%93&q=repo%3Aopenwrt%2Fpackages
+extension%3Alocations&type=Code&ref=advsearch&l=&l=|
other packages using a .locations file]], too:
<code nginx ${CONF_DIR}example.locations>
location /ex/am/ple {
	access_log off; # default: not logging accesses.
	# access_log /proc/self/fd/1 openwrt; # use logd (init forwards stdout).
	# error_log stderr; # default: logging to logd (init forwards stderr).
	error_log /dev/null; # disable error logging after config file is read.
	# (state path of a file for access_log/error_log to the file instead.)
	index index.html;
}
# location /eg/static { … }
</code>

All location blocks in all ''.locations'' files must use different URLs,
since they are all included in the ''${LAN_NAME}.conf'' that is part of the
[[#openwrt_s_defaults|OpenWrt’s Defaults]].
We reserve the ''location /'' for making LuCI available under the root URL,
e.g. [[https://192.168.1.1/|192.168.1.1/]].
All other sites shouldn’t use the root ''location /'' without suffix.
We can make other sites available on the root URL of other domain names, e.g.
on www.example.com/.
In order to do that, we create a ''.conf'' file for every domain name:
see the next section [[#new_server_parts|New Server Parts]].
We can also activate SSL there, as described below in the section
[[#ssl_server_parts|SSL Server Parts]].
We use such server parts also for publishing sites to the internet (WAN)
instead of making them available just in the LAN.

Via ''.conf'' files we can also add directives to the //http// part of the
configuration. The difference to editing the main ''${NGINX_CONF}''
file instead is the following: If the package’s ''nginx.conf'' file is updated
it will only be installed if the old file has not been changed.



==== New Server Parts ====${MSG}


For making the router reachable from the WAN at a registered domain name,
it is not enough to give the name server the internet IP address of the router
(maybe updated automatically by a
[[docs:guide-user:services:ddns:client|DDNS Client]]).
We also need to set up virtual hosting for this domain name by creating an
appropriate server part in a ''${CONF_DIR}*.conf'' file.
All such files are included at the start of Nginx by the default main
configuration of OpenWrt ''${NGINX_CONF}'' as depicted in
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

The following example is a simple template:
<code nginx ${CONF_DIR}${EXAMPLE_COM}.conf>
server {
	listen 80;
	listen [::]:80;
	server_name ${EXAMPLE_COM};
	# location / { … } # root location for this server.
	include '${CONF_DIR}${EXAMPLE_COM}.locations';
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

The [[#openwrt_s_defaults|OpenWrt’s Defaults]] include a ''${LAN_NAME}.conf''
file containing a server part that listens on the LAN address(es) and acts as
//default_server// with ssl on port 443.
For making the domain name accessible in the LAN, too, the corresponding
server part must listen **explicitly** on the local IP address(es), cf. the
official documentation on
[[https://nginx.org/en/docs/http/request_processing.html|request_processing]].
We can include the file ''${LAN_SSL_LISTEN}'' that contains the listen
directives with ssl parameter for all LAN addresses on the HTTP port 443 and is
updated automatically.

The official documentation of the SSL module contains an
[[https://nginx.org/en/docs/http/ngx_http_ssl_module.html#example|
example]],
which includes some optimizations.
The following template is extended similarly:
<code nginx ${CONF_DIR}${EXAMPLE_COM}>
server {
	listen 443 ssl;
	listen [::]:443 ssl;
	include '${LAN_SSL_LISTEN}';
	server_name ${EXAMPLE_COM};
	ssl_certificate '${CONF_DIR}${EXAMPLE_COM}.crt';
	ssl_certificate_key '${CONF_DIR}${EXAMPLE_COM}.key';
	ssl_session_cache ${SSL_SESSION_CACHE_ARG};
	ssl_session_timeout ${SSL_SESSION_TIMEOUT_ARG};
	# location / { … } # root location for this server.
	include '${CONF_DIR}${EXAMPLE_COM}.locations';
}
</code>

For creating a certificate (and its key) we can use Let’s Encrypt by installing
[[https://github.com/Neilpang/acme.sh|ACME Shell Script]]:
<code>opkg update && opkg install acme # and for LuCI: luci-app-acme</code>

For the LAN server in the ''${LAN_NAME}.conf'' file, the init script
''/etc/init.d/nginx'' script installs automatically a self-signed certificate.
We can use this mechanism also for other sites by issuing, e.g.:
<code>$(basename ${NGINX_UTIL}) ${ADD_SSL_FCT} ${EXAMPLE_COM}</code>
  - It adds SSL directives to the server part of \
    ''${CONF_DIR}${EXAMPLE_COM}.conf'' like in the example above.
  - Then, it checks if there is a certificate and key for the given domain name\
    that is valid for at least 13 months or tries to create a self-signed one.
  - When cron is activated, it installs a cron job for renewing the self-signed\
    certificate every year if needed, too. We can activate cron by: \
    <code>service cron enable && service cron start</code>

Beside the ''${LAN_NAME}.conf'' file, the
[[#openwrt_s_defaults|OpenWrt’s Defaults]] include also the
''_redirect2ssl.conf'' file containing a server part that redirects all HTTP
request for inexistent URIs to HTTPS.



==== OpenWrt’s Defaults ====${MSG}


The default main configuration file is:
$(code ${NGINX_CONF})

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
directory ''${CONF_DIR}'' into the http block, especially the following
server part for the LAN:
$(code ${CONF_DIR}${LAN_NAME}.conf)

It pulls in all ''.locations'' files from the directory ''${CONF_DIR}''.
We can install the location parts of different sites there (see above in the
[[#basic|Basic Configuration]]) and re-include them in server parts  of other
''${CONF_DIR}*.conf'' files.
This is needed especially for making them available to the WAN as described
above in the section [[#new_server_parts|New Server Parts]].
All ''.locations'' become available on the LAN through the file
''$(basename ${LAN_SSL_LISTEN}).default'', which contains one of the following
directives for every local IP address:
<code nginx>
	listen IPv4:443 ssl default_server;
	listen [IPv6]:443 ssl default_server;
</code>
The ''${LAN_SSL_LISTEN}'' file contains the same directives without the
parameter ''default_server''.
We can include this file in other server parts that should be reachable in the
LAN through their //server_name//.
Both files ''${LAN_SSL_LISTEN}{,.default}'' are (re-)created if Nginx starts
through its init for OpenWrt or the LAN interface changes.

There is also the following server part that redirects requests for an
inexistent ''server_name'' from HTTP to HTTPS (using an invalid name, more in
the official documentation on
[[https://nginx.org/en/docs/http/request_processing.html|request_processing]]):
$(code ${CONF_DIR}_redirect2ssl.conf)

Nginx’s init file for OpenWrt installs automatically a self-signed certificate
for the LAN server part if needed and possible:
  - Everytime Nginx starts, we check if the LAN is set up for SSL.
  - We add //ssl*// directives (like in the example of the previous section \
    [[#ssl_server_parts|SSL Server Parts]]) to the configuration file \
    ''${CONF_DIR}${LAN_NAME}.conf'' if needed and if it looks “normal”, i.e., \
    it has a ''server_name ${LAN_NAME};'' part.
  - If there is no corresponding certificate that is valid for more than 13 \
    months at ''${CONF_DIR}${LAN_NAME}.{crt,key}'', we create a self-signed one.
  - We activate SSL by including the ssl listen directives from \
    ''${LAN_SSL_LISTEN}.default'' and it becomes available by the default \
    redirect from ''listen *:80;'' in ''${CONF_DIR}_redirect2ssl.conf''
  - If cron is available, i.e., its status is not ''inactive'', we use it \
    to check the certificate for validity once a year and renew it if there \
    are only about 13 months of the more than 3 years life time left.

The points 2, 3 and 5 can be used for other domains, too:
As described in the section [[#new_server_parts|New Server Parts]] above, we
create a server part in ''${CONF_DIR}www.example.com.conf'' with
a corresponding ''server_name www.example.com;'' directive and call
<code>$(basename ${NGINX_UTIL}) ${ADD_SSL_FCT} www.example.com</code>
EOF
