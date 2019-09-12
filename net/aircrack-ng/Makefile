#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=aircrack-ng
PKG_VERSION:=1.5.2
PKG_RELEASE:=$(PKG_SOURCE_VERSION)
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:aircrack-ng:aircrack-ng

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/aircrack-ng/aircrack-ng.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=42f2b48d7f46b39e0d5d2f2a64cbf63f87416a70
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.xz
PKG_MIRROR_HASH:=17893e05278635675a77a3cb0927202ec4df2fc9a742689a7a88e4a8f27a69b6

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_MAINTAINER:=Rick Farina <zerochaos@gentoo.org>

PKG_FIXUP:=autoreconf

PKG_CONFIG_DEPENDS:= \
	CONFIG_AIRCRACK_NG_GCRYPT \
	CONFIG_AIRCRACK_NG_OPENSSL \
	\
	CONFIG_AIRCRACK_NG_OPTIMIZE_SPEED \
	\
	CONFIG_AIRCRACK_NG_HWLOC \
	CONFIG_AIRCRACK_NG_SQLITE3

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/aircrack-ng
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+AIRCRACK_NG_HWLOC:libhwloc +libpcap +libpcre +libpthread $(CXX_DEPENDS)
  DEPENDS += +AIRCRACK_NG_OPENSSL:libopenssl
  DEPENDS += +AIRCRACK_NG_GCRYPT:libgcrypt
  DEPENDS += +AIRCRACK_NG_SQLITE3:libsqlite3
  DEPENDS += +libnl-core +libnl-genl +zlib
  TITLE:=WLAN tools (without airmon-ng) for breaking 802.11 WEP/WPA keys
  URL:=https://www.aircrack-ng.org/
  SUBMENU:=wireless
endef

define Package/aircrack-ng/description
  WLAN tools for breaking 802.11 WEP/WPA keys
endef

define Package/aircrack-ng/config
  source "$(SOURCE)/Config.in"
endef

define Package/airmon-ng
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+wireless-tools +ethtool +procps-ng +CONFIG_PCI_SUPPORT:pciutils +CONFIG_USB_SUPPORT:usbutils
  TITLE:=Bash script designed to turn wireless cards into monitor mode.
  URL:=http://www.aircrack-ng.org/
  SUBMENU:=wireless
endef

define Package/airmon-ng/description
  Bash script designed to turn wireless cards into monitor mode.
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	echo "$(PKG_VERSION)_rev$(PKG_SOURCE_VERSION)" > $(PKG_BUILD_DIR)/VERSION
endef

CONFIGURE_ARGS += \
	--disable-silent-rules \
	--enable-shared \
	--with-experimental \
	--with-libpcap-include=$(STAGING_DIR)/usr/include \
	--with-libpcap-lib=$(STAGING_DIR)/usr/lib \
	--without-opt \
	\
	PYTHON=$(PYTHON) \
	\
	$(if $(CONFIG_AIRCRACK_NG_OPENSSL),,--without-openssl) \
	$(if $(CONFIG_AIRCRACK_NG_GCRYPT),--with-gcrypt,--without-gcrypt) \
	$(if $(CONFIG_AIRCRACK_NG_HWLOC),--enable-hwloc,--disable-hwloc) \
	$(if $(CONFIG_AIRCRACK_NG_SQLITE3),--with-sqlite3=$(STAGING_DIR)/usr,--without-sqlite3)

TARGET_CFLAGS += -Wall -Wextra -ffunction-sections -fdata-sections

ifeq ($(CONFIG_AIRCRACK_NG_OPTIMIZE_SPEED),y)
	TARGET_CFLAGS := $(filter-out -O%,$(TARGET_CFLAGS)) -O3
endif

TARGET_LDFLAGS+= \
	-Wl,--gc-sections

define Package/aircrack-ng/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/* $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
	rm -f $(1)/usr/sbin/airmon-ng
endef

define Package/airmon-ng/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/airmon-ng $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,aircrack-ng))
$(eval $(call BuildPackage,airmon-ng))
