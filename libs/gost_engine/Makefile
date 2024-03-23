include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/openssl-module.mk

PKG_NAME:=gost_engine
PKG_VERSION:=3.0.3
PKG_HASH:=8cf888333d08b8bbcc12e4e8c0d8b258c74dbd67941286ffbcc648c6d3d66735
PKG_LICENSE:=Apache-2.0
PKG_RELEASE:=9

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/gost-engine/engine/archive/v$(PKG_VERSION)

PKG_MAINTAINER:=Artur Petrov <github@phpchain.ru>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

PKG_UNPACK:=$(HOST_TAR) -C "$(PKG_BUILD_DIR)" --strip-components=1 -xzf "$(DL_DIR)/$(PKG_SOURCE)"
PKG_INSTALL:=

define Package/gost_engine/Default
  $(call Package/openssl/engine/Default)
  TITLE:=GOST engine for OpenSSL
  URL:=http://www.openssl.org/
endef

define Package/gost_engine/Default/description
Russian GOST crypto algorithms for OpenSSL.
endef

$(eval $(call Package/openssl/add-engine,gost,libopenssl-gost_engine))
define Package/libopenssl-gost_engine
    $(call Package/gost_engine/Default)
    $(call Package/openssl/engine/Default)
    TITLE+= (library)
    URL:=https://github.com/gost-engine/engine/
endef

define Package/libopenssl-gost_engine/description
$(call Package/gost_engine/Default/description)
This package contains the GOST engine library.

Support ciphers:
GOST2012-GOST8912-GOST8912
GOST2001-GOST89-GOST89
endef

define Package/gost_engine-util
    $(call Package/gost_engine/Default)
    SECTION:=utils
    CATEGORY:=Utilities
    DEPENDS:=libopenssl-gost_engine
    TITLE+= (utilities)
endef

define Package/gost_engine-util/description
$(call Package/gost_engine/Default/description)
This package contains the GOST engine command-line utilities gostsum and gost12sum.
endef

CMAKE_OPTIONS += -DOPENSSL_ENGINES_DIR=/usr/lib/$(ENGINES_DIR)

define Package/libopenssl-gost_engine/install
	$(INSTALL_DIR) $(1)/usr/lib/$(ENGINES_DIR) $(1)/etc/ssl/engines.cnf.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/bin/gost.so \
			$(1)/usr/lib/$(ENGINES_DIR)/
	$(INSTALL_DATA) ./files/gost.cnf $(1)/etc/ssl/engines.cnf.d/
endef

define Package/gost_engine-util/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/{gost12sum,gostsum} \
			$(1)/usr/bin/
endef


$(eval $(call BuildPackage,libopenssl-gost_engine))
$(eval $(call BuildPackage,gost_engine-util))
