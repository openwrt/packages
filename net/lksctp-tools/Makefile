#
# Copyright (C) 2010-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lksctp-tools
PKG_VERSION:=1.0.16
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/lksctp
PKG_MD5SUM:=708bb0b5a6806ad6e8d13c55b067518e

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/lksctp-tools/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=SCTP user-land
  URL:=http://lksctp.sourceforge.net
endef

define Package/libsctp
$(call Package/lksctp-tools/Default)
  SUBMENU:=Networking
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+= library
  URL:=http://lksctp.sourceforge.net
  DEPENDS:=+kmod-sctp
endef

define Package/sctp
$(call Package/lksctp-tools/Default)
  TITLE+= (meta)
  URL:=http://lksctp.sourceforge.net
  DEPENDS:=+libsctp +sctp-tools
endef

define Package/sctp-tools
$(call Package/lksctp-tools/Default)
  TITLE+= tools
  URL:=http://lksctp.sourceforge.net
  DEPENDS:=+libsctp
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/netinet \
		$(STAGING_DIR)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libsctp.{a,so*} \
		$(1)/usr/lib/
endef

define Package/libsctp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libsctp.so.* \
		$(1)/usr/lib/
endef

define Package/sctp/install
	:
endef

define Package/sctp-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/bin/checksctp \
		$(1)/usr/bin/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/bin/sctp_{darn,status,test} \
		$(1)/usr/bin/
endef

$(eval $(call BuildPackage,libsctp))
$(eval $(call BuildPackage,sctp))
$(eval $(call BuildPackage,sctp-tools))
