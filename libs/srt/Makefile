#
# Copyright (C) 2024 Koen Vandeputte <koen.vandeputte@citymesh.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=srt
PKG_VERSION:=1.5.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/haivision/srt/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=d0a8b600fe1b4eaaf6277530e3cfc8f15b8ce4035f16af4a5eb5d4b123640cdd
PKG_MAINTAINER:=Koen Vandeputte <koen.vandeputte@citymesh.com>

PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1

PKG_CONFIG_DEPENDS:= \
  \
  CONFIG_SRT_OPENSSL \
  CONFIG_SRT_MBEDTLS \
  CONFIG_SRT_GNUTLS \
  CONFIG_SRT_NOENCRYPTION \
  \
  CONFIG_SRT_MONOTONIC_CLOCK \
  CONFIG_SRT_BONDING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/srt
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:= +libstdcpp +libatomic
  DEPENDS += +SRT_OPENSSL:libopenssl +SRT_MBEDTLS:libmbedtls +SRT_GNUTLS:libgnutls
  TITLE:=secure reliable transport
  URL:=https://github.com/Haivision/srt
  MENU:=1
endef

define Package/srt/description
  This package provides the Secure Reliable Transport library which
  is mostly used by the gstreamer srt sink plugin
endef

define Package/srt/config
  source "$(SOURCE)/Config.in"
endef

TARGET_LDFLAGS += -Wl,--gc-sections

CMAKE_OPTIONS += \
	-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DENABLE_APPS=OFF \
        -DENABLE_PKTINFO=OFF \
        -DENABLE_SHARED=ON \
        -DENABLE_STATIC=OFF \
        -DENABLE_TESTING=OFF \
        -DENABLE_UNITTESTS=OFF \
        -DUSE_BUSY_WAITING=OFF \
        -DENABLE_BONDING=$(if $(CONFIG_SRT_BONDING),ON,OFF) \
        -DENABLE_MONOTONIC_CLOCK=$(if $(CONFIG_SRT_MONOTONIC_CLOCK),ON,OFF) \
        -DENABLE_ENCRYPTION=$(if $(CONFIG_SRT_OPENSSL)$(CONFIG_SRT_MBEDTLS)$(CONFIG_SRT_GNUTLS),ON,OFF) \
        $(if $(CONFIG_SRT_OPENSSL),-DUSE_ENCLIB=openssl-evp) \
        $(if $(CONFIG_SRT_MBEDTLS),-DUSE_ENCLIB=mbedtls) \
        $(if $(CONFIG_SRT_GNUTLS),-DUSE_ENCLIB=gnutls)

define Package/srt/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsrt.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,srt))
