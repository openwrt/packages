#
# Copyright (C) 2008-2015 OpenWrt.org
# Copyright (C) 2016 Luiz Angelo Daros de Luca
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libvpx
PKG_VERSION:=1.7.0
PKG_RELEASE:=1

PKG_REV:=v$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_REV).tar.gz
PKG_MIRROR_HASH:=be50ff18464d614a08726597ecbd72d1f11ec69ec04df2d9acdf646ecd9adcca
PKG_SOURCE_URL:=https://chromium.googlesource.com/webm/libvpx
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Luiz Angelo Daros de Luca <luizluca@gmail.com>

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_ABI_VERSION:=$(subst $(space),.,$(wordlist 1, 2, $(subst .,$(space),$(PKG_VERSION))))

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libvpx
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libvpx
  URL:=http://www.webmproject.org/
  DEPENDS:=+libpthread
  ABI_VERSION:=$(PKG_ABI_VERSION)
endef

define Package/libvpx/description
   libvpx is a VP8/VP9 Codec SDK.
endef

CONFIGURE_ARGS = \
		--target=generic-gnu \
		--prefix=$(CONFIGURE_PREFIX) \
		--libdir=/usr/lib \
		--enable-static \
		--enable-shared \
        --disable-examples \
        --disable-docs \
        --disable-unit-tests \

# Add --enable-small as openwrt gcc flags are overwritten
ifneq ($(findstring -Os,$(TARGET_CFLAGS)),)
CONFIGURE_ARGS += --enable-small
endif

# libvpx expects gcc as linker but uses $LD if provided
# However, OpenWRT defines LD as *-uclibc-ld and not *-gcc
CONFIGURE_VARS += \
    CROSS=$(GNU_TARGET_NAME) \
	LD="$(TARGET_CC)" \

MAKE_FLAGS += \
	LD="$(TARGET_CC)" \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/vpx/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/vpx/* $(1)/usr/include/vpx/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.{so*,a} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig/
endef

define Package/libvpx/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libvpx))
