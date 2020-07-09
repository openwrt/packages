include $(TOPDIR)/rules.mk

PKG_NAME:=h2o
PKG_VERSION:=2.2.6
PKG_RELEASE:=6

PKG_SOURCE_URL:=https://codeload.github.com/h2o/h2o/tar.gz/v${PKG_VERSION}?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=f8cbc1b530d85ff098f6efc2c3fdbc5e29baffb30614caac59d5c710f7bda201

PKG_MAINTAINER:=James Taylor <james@jtaylor.id.au
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

PKG_BUILD_DEPENDS:=ruby/host libwslay
PKG_BUILD_PARALLEL:=1

CMAKE_OPTIONS:= \
	-DBUILD_SHARED_LIBS=ON \
	-DWITH_MRUBY=OFF

CMAKE_INSTALL:=1

define Package/libh2o-evloop
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=H2O Library compiled with its own event loop
  URL:=https://h2o.examp1e.net/
  DEPENDS:=+libopenssl +zlib +libyaml +ruby
endef

define Package/libh2o
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=H2O Library compiled with libuv
  URL:=https://h2o.examp1e.net/
  DEPENDS:=+libuv +libopenssl +zlib +libyaml +ruby
endef

define Package/libh2o-evloop/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libh2o-evloop.so* $(1)/usr/lib/
endef

define Package/libh2o/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libh2o.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libh2o-evloop))
$(eval $(call BuildPackage,libh2o))
