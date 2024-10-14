#
# This software is licensed under the Public Domain.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sipcalc
PKG_SOURCE_DATE:=2014-10-24
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/sii/sipcalc
PKG_SOURCE_VERSION:=9b97dbca1a0ccaaeb322b8f0a4100dc234cfcc8c
PKG_MIRROR_HASH:=5a9c39c037898128e2909619ee505c0accbce09e85e503d63d18ba805b2af785

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/sipcalc
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=IPv4/IPv6 Calculator
  URL:=https://github.com/sii/sipcalc
endef

define Package/sipcalc/description
   Sipcalc is an advanced ip calculator supporting both IPv4 and IPv6. 
endef

define Package/sipcalc/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/sipcalc $(1)/usr/sbin/sipcalc
endef

$(eval $(call BuildPackage,sipcalc))
