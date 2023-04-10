#
# Copyright (C) 2018 Lucian Cristian
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gddrescue
PKG_VERSION:=1.27
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).orig.tar.xz
PKG_SOURCE_URL:=http://archive.ubuntu.com/ubuntu/pool/universe/g/$(PKG_NAME)
PKG_HASH:=dd8af32d9be5afd7a9b9c34014e44358c3bfb193a612a2cb6547499bb1f76698

PKG_MAINTAINER:=Lucian Cristian <lucian.cristian@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/gddrescue
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Data recovery tool
  URL:=https://www.gnu.org/software/ddrescue/
  DEPENDS:=+libstdcpp
endef

define Package/gddrescue/description
	GNU ddrescue is a data recovery tool. It copies data from one file
	or block device (hard disc, cdrom, etc) to another, trying to rescue
	the good parts first in case of read errors.
endef

CONFIGURE_ARGS += \
	CXX="$(TARGET_CXX)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	CXXFLAGS="$(TARGET_CXXFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)"

define Package/gddrescue/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ddrescue $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ddrescuelog $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,gddrescue))
