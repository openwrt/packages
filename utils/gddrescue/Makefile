#
# Copyright (C) 2018 Lucian Cristian
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gddrescue
PKG_VERSION:=1.25-pre1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/mruffalo/ddrescue
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=5831d7e24070bc700d8f22deaeec56af1149392ce30ae67254096eaf8c9169ab

PKG_MAINTAINER:=Lucian Cristian <lucian.cristian@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/gddrescue
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Data recovery tool
  URL:=https://www.gnu.org/software/ddrescue/
  DEPENDS:=$(CXX_DEPENDS)
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
