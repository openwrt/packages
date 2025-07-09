#
# Copyright (C) 2013-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dump1090
PKG_VERSION:=10.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/flightaware/dump1090
PKG_MIRROR_HASH:=3763c053ae3d7ddf4eee339a88a8f3e5e4af51296d120c0d501330ee260a090e

PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING LICENSE

PKG_BUILD_DEPENDS:=libusb
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=gc-sections lto

include $(INCLUDE_DIR)/package.mk

define Package/dump1090/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Mode S decoder for the Realtek RTL2832U
  URL:=https://github.com/flightaware/dump1090
endef

define Package/dump1090
  $(call Package/dump1090/Default)
  TITLE+= (dump1090)
  DEPENDS+=+librtlsdr +uhttpd +libncurses
endef

define Package/view1090
  $(call Package/dump1090/Default)
  TITLE+= (view1090)
  DEPENDS+=+libncurses
endef

define Package/dump1090/description
 Dump1090 is a Mode S decoder specifically designed for RTLSDR devices.
endef

define Package/view1090/description
 View1090 is a Mode S messages viewer for dump1090 devices.
endef

MAKE_FLAGS += \
	DUMP1090_VERSION=$(PKG_VERSION) \
	BLADERF=no \
	CFLAGS="$(TARGET_CFLAGS)" \
	UNAME="Linux"

ifeq ($(CONFIG_SOFT_FLOAT),y)
MAKE_FLAGS += CPUFEATURES=no
endif

TARGET_LDFLAGS += -Wl,--as-needed

define Package/dump1090/conffiles
/etc/config/dump1090
endef

define Package/dump1090/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/dump1090.init $(1)/etc/init.d/dump1090
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/dump1090.config $(1)/etc/config/dump1090
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DATA) files/dump1090.default $(1)/etc/uci-defaults/00_uhttpd_dump1090
	$(INSTALL_DIR) $(1)/usr/share/dump1090
	$(CP) $(PKG_BUILD_DIR)/public_html/* $(1)/usr/share/dump1090
	$(LN) /var/run/dump1090 $(1)/usr/share/dump1090/data
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dump1090 $(1)/usr/bin
endef

define Package/view1090/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/view1090 $(1)/usr/bin
endef

$(eval $(call BuildPackage,dump1090))
$(eval $(call BuildPackage,view1090))
