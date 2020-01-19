#
# Copyright (C) 2017  Hauke Mehrtens <hauke@hauke-m.de>
# Copyright (C) 2016 - 2020  Stijn Tintel <stijn@linux-ipv6.be>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openzwave
PKG_VERSION:=1.6.1063
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://old.openzwave.com/downloads
PKG_HASH:=8b1b674f825cd3623d2aa9c286edbb05c0ff6537d5d3ee891ae98e21d28de26b
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/openzwave/default
  URL:=http://openzwave.com
  MAINTAINER:=Stijn Tintel <stijn@linux-ipv6.be>
  DEPENDS:=+libpthread +libstdcpp
endef

define Package/openzwave/description
	Open-ZWave is a library that interfaces with selected Z-Wave PC controllers
endef

define Package/libopenzwave
$(call Package/openzwave/default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Open-ZWave Library
endef

define Package/openzwave
$(call Package/openzwave/default)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Open-ZWave MinOZW test utility
  DEPENDS:=+libopenzwave +openzwave-config
endef

define Package/openzwave-config
$(call Package/openzwave/default)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Open-ZWave Device Configs
endef

TARGET_CPPFLAGS+=-Wno-format -Wno-format-security

MAKE_FLAGS += \
	LD="$(TARGET_CROSS)g++" \
	LIBDIR="$(PKG_BUILD_DIR)" \
	PREFIX=$(CONFIGURE_PREFIX) \
	USE_HID="no" \
	ar_option="q" \
	instlibdir=/usr/lib \
	pkgconfigdir=/usr/lib/pkgconfig \
	sysconfdir=/etc/openzwave

define Build/Prepare
	$(call Build/Prepare/Default)
	sed -i -e 's/-O3 //;s/-Werror //' $(PKG_BUILD_DIR)/cpp/build/Makefile
endef

define Package/libopenzwave/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libopenzwave.so* $(1)/usr/lib/
endef

define Package/openzwave/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/MinOZW $(1)/usr/bin/
endef

define Package/openzwave-config/install
	$(INSTALL_DIR) $(1)/etc/
	$(CP) $(PKG_INSTALL_DIR)/etc/openzwave $(1)/etc/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/openzwave $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libopenzwave.* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libopenzwave.pc $(1)/usr/lib/pkgconfig/
endef

$(eval $(call BuildPackage,libopenzwave))
$(eval $(call BuildPackage,openzwave))
$(eval $(call BuildPackage,openzwave-config))
