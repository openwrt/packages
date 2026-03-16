#
# Copyright (C) 2016 Bruno Randolf (br1@einfach.org)
#               2019 Nick Hainke (vincent@systemli.org)
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libradiotap
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/radiotap/radiotap-library
PKG_SOURCE_DATE:=2023-10-09
PKG_SOURCE_VERSION:=ee71d224e0faeb9ec4e198d587d4e5aac60d4afe
PKG_MIRROR_HASH:=c829fcbaaef8ab15467b241fca331d484825bb8de1bf3a59bf29727345ec88d3

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
