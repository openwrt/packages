include $(TOPDIR)/rules.mk

PKG_NAME:=gost_engine
PKG_VERSION:=1.1.0.3
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/gost-engine/engine/archive/v$(PKG_VERSION)
PKG_HASH:=fff725052e82c9adb5b738729b30141f61ac91fa457a4f4b5de18b8b24092f75

PKG_MAINTAINER:=Artur Petrov <github@phpchain.ru>
PKG_LICENSE:=OpenSSL

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

PKG_UNPACK:=$(HOST_TAR) -C "$(PKG_BUILD_DIR)" --strip-components=1 -xzf "$(DL_DIR)/$(PKG_SOURCE)"
PKG_INSTALL:=

ENGINES_DIR:=engines-1.1

define Package/libopenssl-gost_engine
    SECTION:=libs
    CATEGORY:=Libraries
    SUBMENU:=SSL
    TITLE:=Russian GOST crypto algorithms for OpenSSL
    URL:=https://github.com/gost-engine/engine/
    DEPENDS:=libopenssl @OPENSSL_ENGINE @OPENSSL_WITH_GOST +libopenssl-conf
endef

define Package/libopenssl-gost_engine/description
A reference implementation of the Russian GOST crypto algorithms for OpenSSL
endef

CMAKE_OPTIONS += -DOPENSSL_ENGINES_DIR=/usr/lib/$(ENGINES_DIR)

define Package/libopenssl-gost_engine/install
	$(INSTALL_DIR) $(1)/usr/lib/$(ENGINES_DIR)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/bin/gost.so \
			$(1)/usr/lib/$(ENGINES_DIR)/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/{gost12sum,gostsum} \
			$(1)/usr/bin/
endef

$(eval $(call BuildPackage,libopenssl-gost_engine))