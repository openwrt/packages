#
# Copyright (C) 2017 Michael Heimpold <mhei@heimpold.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libiio
PKG_VERSION:=0.10
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/analogdevicesinc/libiio/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=002d57f35715821efae66479859bc5357b4d8d33bfff1446b4e17b02ae2c10d2

PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=COPYING.txt

PKG_MAINTAINER:=Michael Heimpold <mhei@heimpold.de>

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libiio
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library for interfacing with Linux IIO devices
  URL:=https://github.com/analogdevicesinc/libiio
  DEPENDS:=+PACKAGE_libaio:libaio +PACKAGE_libusb-1.0:libusb-1.0 +libxml2
endef

define Package/libiio/description
  libiio is used to interface to the Linux Industrial Input/Output (IIO) Subsystem.
  The Linux IIO subsystem is intended to provide support for devices that in some
  sense are analog to digital or digital to analog converters (ADCs, DACs). This
  includes, but is not limited to ADCs, Accelerometers, Gyros, IMUs, Capacitance
  to Digital Converters (CDCs), Pressure Sensors, Color, Light and Proximity Sensors,
  Temperature Sensors, Magnetometers, DACs, DDS (Direct Digital Synthesis),
  PLLs (Phase Locked Loops), Variable/Programmable Gain Amplifiers (VGA, PGA),
  and RF transceivers. You can use libiio natively on an embedded Linux
  target (local mode), or use libiio to communicate remotely to that same target
  from a host Linux, Windows or MAC over USB or Ethernet or Serial.
endef

define Package/iiod
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Linux IIO daemon
  URL:=https://github.com/analogdevicesinc/libiio
  DEPENDS:=+libiio
endef

define Package/libiio/description
  Daemon to access IIO devices via network.
endef

define Package/iio-utils
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Linux IIO tools
  URL:=https://github.com/analogdevicesinc/libiio
  DEPENDS:=+libiio
endef

define Package/iio-utils/description
  Command tools for IIO devices.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/iio.h $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libiio.so* $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libiio.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libiio/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libiio.so* $(1)/usr/lib/
endef

define Package/iiod/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/iiod $(1)/usr/sbin/
endef

define Package/iio-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libiio))
$(eval $(call BuildPackage,iiod))
$(eval $(call BuildPackage,iio-utils))
