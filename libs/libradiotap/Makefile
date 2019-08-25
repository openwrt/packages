#
# Copyright (C) 2016 Bruno Randolf (br1@einfach.org)
#               2019 Nick Hainke (vincent@systemli.org)
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libradiotap
PKG_VERSION:=2019-04-15
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/radiotap/radiotap-library.git
PKG_SOURCE_VERSION:=1ca6b4f0d7225971ebcadf575c8f9e00ee55e840
PKG_MIRROR_HASH:=59d2350d569c4027ca1b23ebbe3519852e194184c1aaa04308712235f387e422

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1

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
