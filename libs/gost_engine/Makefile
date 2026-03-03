include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/openssl-module.mk

PKG_NAME:=gost_engine
PKG_VERSION:=3.0.3
PKG_RELEASE:=11

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/gost-engine/engine
PKG_MIRROR_HASH:=ad88b0bc4ede265bc91757f0bb9777a381f8e271faa43992a054ddd5f435ad88

PKG_MAINTAINER:=Artur Petrov <github@phpchain.ru>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/gost_engine/Default
  $(call Package/openssl/engine/Default)
  TITLE:=GOST engine for OpenSSL
  URL:=https://github.com/gost-engine/engine
endef

define Package/gost_engine/Default/description
Russian GOST crypto algorithms for OpenSSL.
endef

$(eval $(call Package/openssl/add-engine,gost,libopenssl-gost_engine))
define Package/libopenssl-gost_engine
    $(call Package/gost_engine/Default)
    $(call Package/openssl/engine/Default)
    TITLE+= (library)
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
    DEPENDS:=+libopenssl-gost_engine
    TITLE+= (utilities)
endef

define Package/gost_engine-util/description
$(call Package/gost_engine/Default/description)
This package contains the GOST engine command-line utilities gostsum and gost12sum.
endef

CMAKE_OPTIONS += -DOPENSSL_ENGINES_DIR=/usr/lib/$(ENGINES_DIR)

define Package/libopenssl-gost_engine/install
	$(INSTALL_DIR) $(1)/usr/lib $(1)/usr/lib/$(ENGINES_DIR) $(1)/etc/ssl/modules.cnf.d
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libgost.so \
			$(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/$(ENGINES_DIR)/gost.so \
			$(1)/usr/lib/$(ENGINES_DIR)/
	$(INSTALL_DATA) ./files/gost.cnf $(1)/etc/ssl/modules.cnf.d/
endef

define Package/gost_engine-util/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/{gost12sum,gostsum} \
			$(1)/usr/bin/
endef


$(eval $(call BuildPackage,libopenssl-gost_engine))
$(eval $(call BuildPackage,gost_engine-util))
