include $(TOPDIR)/rules.mk

PKG_NAME:=mitmproxy
PKG_VERSION:=12.3.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/mitmproxy/mitmproxy/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=699d61561cf20f374fd654a30afc0e82af609976b1f589c42e1809210eb6f89b

PKG_MAINTAINER:=Your Real Name <your.real@email.address>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:mitmproxy:mitmproxy

PKG_BUILD_DEPENDS:=python-setuptools/host

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

define Package/mitmproxy
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Interactive TLS-capable intercepting HTTP proxy
  URL:=https://mitmproxy.org/
  DEPENDS:= \
    +python3-light \
    +python3-asyncio \
    +python3-codecs \
    +python3-logging \
    +python3-openssl \
    +python3-urllib \
    +python3-uuid \
    +python3-xml \
    +python3-aioquic \
    +python3-argon2-cffi \
    +python3-asgiref \
    +python3-bcrypt \
    +python3-brotli \
    +python3-certifi \
    +python3-cryptography \
    +python3-flask \
    +python3-h11 \
    +python3-h2 \
    +python3-kaitaistruct \
    +python3-ldap3 \
    +python3-mitmproxy-rs \
    +python3-pyopenssl \
    +python3-pyparsing \
    +python3-pyperclip \
    +python3-ruamel-yaml \
    +python3-sortedcontainers \
    +python3-tornado \
    +python3-wsproto
endef

define Package/mitmproxy/description
  mitmproxy is an interactive, TLS-capable intercepting proxy for
  HTTP/1, HTTP/2, HTTP/3 and WebSockets.

  This package provides mitmdump (command-line) and mitmweb (web
  interface). The curses console (mitmproxy) is not included.
endef

define Package/mitmproxy/conffiles
/etc/config/mitmproxy
/etc/mitmproxy/
endef

define Py3Package/mitmproxy/filespec
+|$(PYTHON3_PKG_DIR)
-|$(PYTHON3_PKG_DIR)/mitmproxy/tools/console
endef

define Py3Package/mitmproxy/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mitmdump $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mitmweb $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/mitmproxy.config $(1)/etc/config/mitmproxy
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mitmproxy.init $(1)/etc/init.d/mitmproxy
endef

$(eval $(call Py3Package,mitmproxy))
$(eval $(call BuildPackage,mitmproxy))
$(eval $(call BuildPackage,mitmproxy-src))
