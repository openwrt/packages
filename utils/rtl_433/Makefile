#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=rtl_433
PKG_VERSION:=23.11
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/merbanan/rtl_433/tar.gz/$(PKG_VERSION)?
PKG_HASH:=1260c58400bf35832ac1b76cb3cccf3dc1335ffa2416909c63c7d7060c74663b

PKG_MAINTAINER:=Jasper Scholte <NightNL@outlook.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/rtl_433/default
  TITLE:=Generic radio frequency data receiver
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+librtlsdr +rtl-sdr +libtool-bin
  URL:=https://github.com/merbanan/rtl_433
endef

define Package/rtl_433
  $(call Package/rtl_433/default)
  VARIANT:=nossl
endef

define Package/rtl_433-ssl
  $(call Package/rtl_433/default)
  TITLE+= (with SSL support)
  DEPENDS+= +libopenssl
  VARIANT:=ssl
endef

define Package/rtl_433/description
  rtl_433 (despite the name) is a generic data receiver, mainly for the 433.92 MHz, 868 MHz (SRD), 315 MHz, 345 MHz, and 915 MHz ISM bands.

  To use it with OpenWrt you need a Realtek RTL2832 based DVB USB dongle (SoapySDR is not supported).
endef

define Package/rtl_433-ssl/description
  $(call Package/rtl_433/description)

  This package includes OpenSSL support which allows you to send data to influxDB/MQTT using TLS.
endef

CMAKE_OPTIONS += -DENABLE_SOAPYSDR=NO
ifeq ($(BUILD_VARIANT),ssl)
  CMAKE_OPTIONS += -DENABLE_OPENSSL=ON
else
  CMAKE_OPTIONS += -DENABLE_OPENSSL=OFF
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/rtl_433.h $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/rtl_433_devices.h $(1)/usr/include
endef

define Package/rtl_433/install
	$(INSTALL_DIR) $(1)/etc/rtl_433
	$(CP) $(PKG_INSTALL_DIR)/usr/etc/rtl_433/*.conf $(1)/etc/rtl_433
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/rtl_433 $(1)/usr/bin
endef

define Package/rtl_433-ssl/install
	$(call Package/rtl_433/install,$(1))
endef

$(eval $(call BuildPackage,rtl_433))
$(eval $(call BuildPackage,rtl_433-ssl))
