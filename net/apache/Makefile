#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=apache
PKG_VERSION:=2.4.41
PKG_RELEASE:=1
PKG_SOURCE_NAME:=httpd

PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@APACHE/httpd/
PKG_HASH:=133d48298fe5315ae9366a0ec66282fa4040efa5d566174481077ade7d18ea40

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Thomas Heil <heil@terminal-consulting.de>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_CPE_ID:=cpe:/a:apache:http_server

PKG_BUILD_PARALLEL:=1

PKG_INSTALL:=1

PKG_CONFIG_DEPENDS:= \
	CONFIG_APACHE_HTTP2

PKG_FIXUP:=autoreconf

ADDITIONAL_MODULES:=
ifeq ($(CONFIG_APACHE_HTTP2),y)
  ADDITIONAL_MODULES += --enable-http2
endif
ifneq ($(CONFIG_APACHE_HTTP2),y)
  ADDITIONAL_MODULES += --enable-http2=no
endif

include $(INCLUDE_DIR)/package.mk

define Package/apache/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=The Apache Web Server
  URL:=https://httpd.apache.org/
endef

define Package/apache/Default/description
 The Apache Web Server is a powerful and flexible HTTP/1.1 compliant
 web server.  Originally designed as a replacement for the NCSA HTTP
 Server, it has grown to be the most popular web server on the Internet.
endef

define Package/apache/config
  source "$(SOURCE)/Config.in"
endef

define Package/apache
$(call Package/apache/Default)
  DEPENDS:=+libapr +libaprutil +libpcre +libopenssl +unixodbc +zlib +APACHE_HTTP2:libnghttp2
endef

define Package/apache/description
$(call Package/apache/Default/description)
 .
 This package contains the Apache web server and utility programs.
 .
 Take care that you don't include apache at the moment into your image
 please select it only as module because busybox will override
 /usr/sbin/httpd. It'll be solved soon. If you need to include this
 package in the image anyway, remove httpd from busybox
 (Base system --> Configuration --> Networking Utilities --> httpd).
 Also you should take care for the initscripts, apache's httpd isn't
 compatible with the one from busybox, so if you want to use apache
 for running your webif, you'll need to change the parameters in the
 scripts and configure the rest in /etc/httpd.conf.
endef

define Package/apache/conffiles
/etc/apache2/httpd.conf
/etc/apache2/extra/httpd-autoindex.conf
/etc/apache2/extra/httpd-dav.conf
/etc/apache2/extra/httpd-default.conf
/etc/apache2/extra/httpd-info.conf
/etc/apache2/extra/httpd-languages.conf
/etc/apache2/extra/httpd-manual.conf
/etc/apache2/extra/httpd-mpm.conf
/etc/apache2/extra/httpd-multilang-errordoc.conf
/etc/apache2/extra/httpd-ssl.conf
/etc/apache2/extra/httpd-userdir.conf
/etc/apache2/extra/httpd-vhosts.conf
/etc/apache2/magic
/etc/apache2/mime.types
endef

define Package/apache-icons
$(call Package/apache/Default)
  TITLE:=Icons from Apache
  DEPENDS:=apache
endef

define Package/apache-icons/description
$(call Package/apache/Default/description)
 .
 This package contains the icons from Apache.
endef

CONFIGURE_ARGS+= \
	--datadir=/usr/share/apache2 \
	--disable-authnz-ldap \
	--disable-imagemap \
	--disable-ldap \
	--disable-luajit \
	--enable-authn-alias \
	--enable-authn-anon \
	--enable-cache \
	--enable-cgi \
	--enable-cgid \
	--enable-dbd \
	--enable-disk-cache \
	--enable-exception-hook \
	--enable-file-cache \
	--enable-layout=OpenWrt \
	--enable-mem-cache \
	--enable-mods-shared=all \
	--enable-mpms-shared=all \
	--enable-so \
	--libexecdir=/usr/lib/apache2 \
	--sysconfdir=/etc/apache2 \
	--with-apr-util="$(STAGING_DIR)/usr/bin/apu-1-config" \
	--with-apr="$(STAGING_DIR)/usr/bin/apr-1-config" \
	--with-mpm=prefork \
	--with-pcre="$(STAGING_DIR)/usr/bin/pcre-config" \
	--with-ssl

CONFIGURE_VARS += \
	ap_cv_void_ptr_lt_long=no

define Build/Prepare
	$(call Build/Prepare/Default)
	$(INSTALL_DATA) ./files/openwrt.layout $(PKG_BUILD_DIR)/config.layout
endef

define Build/InstallDev
	rm -rf	$(PKG_INSTALL_DIR)/usr/man/ \
		$(PKG_INSTALL_DIR)/usr/share/manual/
	# if you need docs take a look into the build-dir :)
	$(INSTALL_DIR) $(1)/etc
	$(CP)   $(PKG_INSTALL_DIR)/etc/* \
		$(1)/etc
	$(INSTALL_DIR) $(1)/usr/include/apache
	$(CP)	$(PKG_INSTALL_DIR)/usr/include/* \
		$(1)/usr/include/apache
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP)   $(PKG_INSTALL_DIR)/usr/lib/httpd.exp \
		$(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP)   $(PKG_INSTALL_DIR)/usr/sbin/* \
		$(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/share
	$(CP)   $(PKG_INSTALL_DIR)/usr/share/* \
		$(1)/usr/share
endef

define Package/apache/preinst
	rm /usr/sbin/httpd
	echo -e "You should take a look in the initscripts, busybox's httpd \n\
	uses some parameters which are maybe unsupported by apache."
endef

define Package/apache/install
	$(INSTALL_DIR) $(1)/usr/sbin
	# we don't need apxs on the router, it's just for building apache modules.
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/{ab,dbmmanage,htdbm,htdigest,htpasswd,httxt2dbm,logresolve} $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/{apachectl,checkgid,envvars,envvars-std,htcacheclean,httpd,rotatelogs} $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/httpd.exp $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/share
	$(CP) $(PKG_INSTALL_DIR)/usr/share/{error,htdocs,cgi-bin,build} $(1)/usr/share/
	$(INSTALL_DIR) $(1)/etc/apache
	$(CP) $(PKG_INSTALL_DIR)/etc/apache/{httpd.conf,magic,mime.types,extra} $(1)/etc/apache/
endef

define Package/apache/postrm
	rm -rf /usr/sbin/httpd
	ln -s /bin/busybox /usr/sbin/httpd
	echo -e "You may need to change your initscripts back for the use \n\
		with busybox's httpd."
endef

define Package/apache-icons/install
	$(INSTALL_DIR) $(1)/usr/share
	$(CP) $(PKG_INSTALL_DIR)/usr/share/icons $(1)/usr/share/
endef

$(eval $(call BuildPackage,apache))
$(eval $(call BuildPackage,apache-icons))
