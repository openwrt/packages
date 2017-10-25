#
# Copyright (C) 2012-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bluelog
PKG_VERSION:=1.1.2
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=ftp://ftp.digifail.com/software/bluelog
PKG_HASH:=9750b007daffaffecea3b8dd2332bf74cc24955c307861197a20d04d845bc412

OUI_SOURCE:=oui-2016-05-30.txt.gz
OUI_URL:=http://sources.lede-project.org/
OUI_MD5SUM:=38048729fdb5a7a7e0c5db6a51dc2dd1

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/bluelog/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Bluetooth scanner and logger
  URL:=http://www.digifail.com/software/bluelog.shtml
  DEPENDS:=+bluez-libs +kmod-bluetooth
endef

define Package/bluelog/Default/description
  Bluelog is a simple Bluetooth scanner designed to tell you how many
  discoverable devices there are in an area as quickly as possible. It is
  intended to be used as a site survey tool, identifying the number of possible
  Bluetooth targets there are in the surrounding environment.
endef

define Package/bluelog
  $(call Package/bluelog/Default)
endef

define Package/bluelog/description
  $(call Package/bluelog/Default/description)
endef

define Package/bluelog-live
  $(call Package/bluelog/Default)
  TITLE+= (live output)
  DEPENDS+= bluelog
endef

define Package/bluelog-live/description
  $(call Package/bluelog/Default/description)
  This package contains the files for "Bluelog Live", an optional mode of
  Bluelog which creates a real-time webpage of discovered Bluetooth devices.
endef

define Download/oui.txt
  FILE:=$(OUI_SOURCE)
  URL:=$(OUI_URL)
  MD5SUM:=$(OUI_MD5SUM)
endef

TARGET_CFLAGS += -DOPENWRT

MAKE_FLAGS += \
	 LIBS="$(TARGET_LDFLAGS) -lbluetooth -lm"

define Build/Prepare
	$(eval $(call Download,oui.txt))
	$(Build/Prepare/Default)
	zcat $(DL_DIR)/$(OUI_SOURCE) > $(PKG_BUILD_DIR)/oui.tmp
endef

define Package/bluelog/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/bluelog $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/bluelog.init $(1)/etc/init.d/bluelog
endef

define Package/bluelog-live/install
	$(INSTALL_DIR) $(1)/www/bluelog
	$(CP) $(PKG_INSTALL_DIR)/usr/share/bluelog/*.html $(1)/www/bluelog/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/share/bluelog/openwrt.css \
		$(1)/www/bluelog/style.css
	$(INSTALL_DIR) $(1)/www/bluelog/images
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/share/bluelog/images/digifail_logo.png \
		$(PKG_INSTALL_DIR)/usr/share/bluelog/images/email.png \
		$(PKG_INSTALL_DIR)/usr/share/bluelog/images/favicon.png \
		$(PKG_INSTALL_DIR)/usr/share/bluelog/images/openwrt_logo.png \
		$(PKG_INSTALL_DIR)/usr/share/bluelog/images/qrcontact.png \
		$(1)/www/bluelog/images/
	$(INSTALL_DIR) $(1)/www/cgi-bin
	$(CP) $(PKG_INSTALL_DIR)/usr/share/bluelog/cgi-bin/* $(1)/www/cgi-bin/
endef

$(eval $(call BuildPackage,bluelog))
$(eval $(call BuildPackage,bluelog-live))
