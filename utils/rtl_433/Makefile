#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=rtl_433
PKG_VERSION:=25.02
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/merbanan/rtl_433/tar.gz/$(PKG_VERSION)?
PKG_HASH:=5a409ea10e6d3d7d4aa5ea91d2d6cc92ebb2d730eb229c7b37ade65458223432

PKG_MAINTAINER:=Jasper Scholte <NightNL@outlook.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:rtl_433_project:rtl_433

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

define Package/conffiles
/etc/config/rtl_433
endef

CMAKE_OPTIONS += -DFORCED_GIT_DIR=$(PKG_BUILD_DIR)/.git -DENABLE_SOAPYSDR=NO
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
	$(INSTALL_DIR) \
		$(1)/etc/config \
		$(1)/etc/init.d \
		$(1)/etc/rtl_433 \
		$(1)/usr/bin
	$(INSTALL_CONF) ./files/rtl_433.conf $(1)/etc/config/rtl_433
	$(INSTALL_BIN) ./files/rtl_433.init $(1)/etc/init.d/rtl_433
	$(CP) $(PKG_INSTALL_DIR)/etc/rtl_433/*.conf $(1)/etc/rtl_433
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/rtl_433 $(1)/usr/bin
endef

define Package/rtl_433-ssl/install
	$(call Package/rtl_433/install,$(1))
endef

$(eval $(call BuildPackage,rtl_433))
$(eval $(call BuildPackage,rtl_433-ssl))
