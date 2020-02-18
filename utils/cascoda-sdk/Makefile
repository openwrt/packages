# Copyright (C) 2020 Cascoda Ltd.

include $(TOPDIR)/rules.mk

PKG_NAME:=cascoda-sdk
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Cascoda/cascoda-sdk.git
PKG_SOURCE_DATE:=2020-02-04
PKG_SOURCE_VERSION:=745711e26b31c87d707ffc8054a94e3086be08f5

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_SOURCE_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_SOURCE_VERSION)
PKG_MIRROR_HASH:=64e27b514b7f07e3e8904170391d02aeb2fd561d043c40a853c4166928f28e09

PKG_MAINTAINER:=Elie El Khoury <e.khoury@cascoda.com>, Ciaran Woodward <c.woodward@cascoda.com>

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_CHECK_FORMAT_SECURITY:=0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/cascoda-sdk
  SECTION:=cascoda-sdk
  DEPENDS:=+libpthread +libstdcpp
  CATEGORY:=Utilities
  TITLE:=Cascoda utilities
endef

define Package/cascoda-sdk/description
  Cascoda Utilities: This package installs the following utilities

	cliapp               - A command line interface to the Openthread stack.
	sniffer              - An example program for sniffing 802.15.4 traffic on a specific channel.
	ncpapp               - Network Co-Processor for interacting with openthread wpantund.
	ot-server-standalone - A server program able to connect to thread devices and interpret sensor data.
	serial-adapter       - A useful program for interacting with a serial application running on baremetal.
	usb_test             - An application that tests the USB communications link for reliability and speed.
endef

CMAKE_OPTIONS += -DBUILD_TESTING:Bool=OFF

define Build/Configure
  $(call Build/Configure/Default,--with-linux-headers=$(LINUX_DIR))
	sed -i '/MBEDTLS_HAVE_ASM/d' $(PKG_BUILD_DIR)/_deps/openthread-src/third_party/mbedtls/mbedtls-config.h
endef

define Package/cascoda-sdk/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/bin/cliapp $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/bin/sniffer $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/bin/ncpapp $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/bin/ot-server-standalone $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/bin/serial-adapter $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/bin/usb_test $(1)/usr/bin
endef

$(eval $(call BuildPackage,cascoda-sdk))
