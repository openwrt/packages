include $(TOPDIR)/rules.mk

PKG_NAME:=gost_engine
PKG_VERSION:=1.1.0.3
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/gost-engine/engine/archive/v$(PKG_VERSION)
# Use 'skip' here, and let the build system fill this for you with `make package/openssl-gostengine/{download,check} FIXUP=1`
#PKG_HASH:=skip
PKG_HASH:=fff725052e82c9adb5b738729b30141f61ac91fa457a4f4b5de18b8b24092f75

# Please consider adding yourself as the maintainer
PKG_MAINTAINER:=Artur Petrov <github@phpchain.ru>
PKG_LICENSE:=OpenSSL
# the current master & openssl_1_1_1 branches have an actual license file, missing in current releases:
#PKG_LICENSE:=Apache-2.0
#PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# The package tarball extracts to `engine-1.1.0.3`, which may cause confusion.  Use the full name with this:
PKG_UNPACK:=$(HOST_TAR) -C "$(PKG_BUILD_DIR)" --strip-components=1 -xzf "$(DL_DIR)/$(PKG_SOURCE)"
#PKG_BUILD_DIR:=$(BUILD_DIR)/engine-$(PKG_VERSION)
# the package does not understand `make install`
PKG_INSTALL:=

ENGINES_DIR:=engines-1.1

define Package/libopenssl-gost_engine
    SECTION:=libs
    CATEGORY:=Libraries
    SUBMENU:=SSL
    TITLE:=Russian GOST crypto algorithms for OpenSSL
    URL:=https://github.com/gost-engine/engine/
    DEPENDS:=libopenssl @OPENSSL_ENGINE @OPENSSL_WITH_GOST +libopenssl-conf
    #DEPENDS:=libopenssl @OPENSSL_ENGINE +libopenssl-conf
endef

define Package/libopenssl-gost_engine/description
A reference implementation of the Russian GOST crypto algorithms for OpenSSL
endef

CMAKE_OPTIONS += -DOPENSSL_ENGINES_DIR=/usr/lib/$(ENGINES_DIR)

define Package/libopenssl-gost_engine/install
	$(INSTALL_DIR) $(1)/opt/lib/$(ENGINES_DIR)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/bin/gost.so \
			$(1)/opt/lib/$(ENGINES_DIR)/
	$(INSTALL_DIR) $(1)/opt/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/{gost12sum,gostsum} \
			$(1)/opt/bin/
endef

$(eval $(call BuildPackage,libopenssl-gost_engine))