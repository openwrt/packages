#
# Copyright (C) 2016 Bruno Randolf (br1@einfach.org)
#               2019 Nick Hainke (vincent@systemli.org)
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libradiotap
PKG_VERSION:=2020-06-22
PKG_RELEASE:=5

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/radiotap/radiotap-library.git
PKG_SOURCE_VERSION:=94984dd829a605a2d7af55241145c159607f3b30
PKG_MIRROR_HASH:=1cd4e736534d33cc1a1a0eecce8ce1ea6a93686bf0c8f37635753eea94764bb2

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libradiotap
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=Radiotap Parser Library
	URL:=https://www.radiotap.org/
endef

define Package/libradiotap/description
	Library that supplies additional information about frames from the driver to userspace applications.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/radiotap* $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libradiotap.so* $(1)/usr/lib/
endef

define Package/libradiotap/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libradiotap.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libradiotap))
