include $(TOPDIR)/rules.mk

PKG_NAME:=zlog
PKG_VERSION:=1.2.15
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/HardySimpson/$(PKG_NAME)/archive/refs/tags/$(PKG_VERSION).tar.gz?
PKG_HASH:=00037ab8d52772a95d645f1dcfd2c292b7cea326b54e63e219a5b7fdcb7e6508
PKG_MAINTAINER:=Marko Ratkaj <markoratkaj@gmail.com>

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/zlog
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Pure C logging library
  URL:=http://hardysimpson.github.io/zlog/
  LICENSE:=LGPL-2.1-or-later
  LICENSE_FILES:=COPYING
endef

MAKE_FLAGS+= \
	PREFIX="$(PKG_INSTALL_DIR)/usr"

define Package/zlog/description
  zlog is a reliable, high-performance, thread safe, flexible, clear-model, pure C logging library.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/ $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libzlog.* $(1)/usr/lib/
endef

define Package/zlog/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libzlog.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,zlog))
