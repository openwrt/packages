include $(TOPDIR)/rules.mk

PKG_NAME:=upodman
PKG_VERSION:=0.98.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/oskarirauta/upodman/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=c05eddfe584fcb4e7e1a8893d676356b6332fd3ee6d292793097d16dcc33e6b9

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/upodman
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Podman manager via Ubus
  URL:=https://github.com/oskarirauta/upodman
  DEPENDS:=+libjson-c +libstdcpp +libubox +libuci +libblobmsg-json +libubus +podman
endef

define Package/upodman/description
  upodman extends ubus with bindings to podman and allows
  controlling and statistics over pods and containers through
  ubus.

  upodman is written in C++ except for ubus parts which are
  externed from C. It uses staticly linked libcurl for unix
  socket operations, because system's default libcurl might
  not support unix sockets.
endef

MAKE_VARS += \
	BUILD_DIR="$(PKG_BUILD_DIR)"

CURL_VERSION:=7.87.0
CURL_PATH:=$(PKG_BUILD_DIR)/curl-$(CURL_VERSION)
CONFIGURE_PATH:=curl-$(CURL_VERSION)

CONFIGURE_ARGS+= \
		--disable-debug --enable-optimize --disable-curldebug --disable-ares \
		--enable-rt --disable-ech --enable-shared=no --enable-static=yes --enable-http \
		--disable-ftp --disable-file --disable-ldap --disable-ldaps --disable-rtsp \
		--disable-proxy --disable-dict --disable-telnet --disable-tftp --disable-pop3 \
		--disable-imap --disable-smb --disable-smtp --disable-gopher --disable-mqtt \
		--disable-manual --disable-ipv6 --enable-pthreads --enable-verbose --disable-sspi \
		--disable-crypto-auth --disable-ntlm --disable-ntlm-wb --disable-tls-srp \
		--enable-unix-sockets --disable-cookies --disable-socketpair --disable-http-auth \
		--disable-doh --disable-mime --disable-dateparse --disable-netrc --disable-progress-meter \
		--disable-dnsshuffle --enable-get-easy-options --disable-alt-svc --disable-headers-api \
		--disable-hsts --disable-websockets --without-schannel --without-secure-transport \
		--without-amissl --without-ssl --without-zlib --without-brotli --without-zstd \
		--without-gssapi --without-ca-bundle --without-libpsl --without-libgsasl \
		--without-libssh2 --without-libssh --without-wolfssh --without-librtmp \
		--without-winidn --without-libidn2 --without-nghttp2 --without-ngtcp2 \
		--without-nghttp3 --without-quiche --without-msh3 \
		--without-zsh-functions-dir --without-fish-functions-dir

define Build/Configure
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	mkdir -p $(CURL_PATH)
	$(TAR) xzf $(PKG_BUILD_DIR)/dl/curl-$(CURL_VERSION).tar.gz -C $(PKG_BUILD_DIR)
endef

define Build/Configure
	$(call Build/Configure/Default)
	$(SED) 's#DIST_SUBDIRS = \$$(SUBDIRS) tests packages scripts include docs#DIST_SUBDIRS = \$$(SUBDIRS) packages scripts include#g' $(CURL_PATH)/Makefile
	$(SED) 's#cd docs && \$$(MAKE) install#echo not-installing-docs#g' $(CURL_PATH)/Makefile
	$(SED) 's#cd docs/libcurl && \$$(MAKE) install#echo not-installing-docs#g' $(CURL_PATH)/Makefile
	$(SED) 's#SUBDIRS = ../docs#SUBDIRS =#g' $(CURL_PATH)/src/Makefile
	$(SED) 's#SUBDIRS = ../docs#SUBDIRS =#g' $(CURL_PATH)/src/Makefile.am
endef

define Build/Compile/Curl
	+$(MAKE_VARS) \
	$(MAKE) $(PKG_JOBS) -C $(CURL_PATH) \
		$(MAKE_FLAGS);
endef

define Build/Install/Curl
	$(MAKE_VARS) \
	$(MAKE) -C $(CURL_PATH) \
		$(MAKE_FLAGS) \
	DESTDIR="$(CURL_PATH)/inst" \
	install ;
endef

define Build/Compile
	$(call Build/Compile/Curl)
	$(call Build/Install/Curl)
	$(call Build/Compile/Default)
endef

define Package/upodman/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/upodman $(1)/usr/bin/
	$(INSTALL_BIN) ./files/upodman.init $(1)/etc/init.d/upodman
endef

$(eval $(call BuildPackage,upodman))
