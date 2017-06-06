#
# Copyright (C) 2007-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=efivar
PKG_VERSION:=30
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/rhinstaller/efivar/releases/download/$(PKG_VERSION)/ \
	http://mirror.opencompute.org/onie/
PKG_HASH:=1f5720a9434ddb29a5cb8213e4e3973e212d90eff95dd9b173a5444f48b5128b
PKG_MAINTAINER:=Curt Brune <curt@cumulusnetworks.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

PKG_LICENSE:=LGPLv2.1

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/efivar
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=@TARGET_x86||@TARGET_arm64 +libpopt
  TITLE:=Tools and libraries to manipulate EFI variables
  URL:=https://github.com/rhinstaller/efivar
endef

CONFIGURE_ARGS +=
TARGET_CFLAGS +=
TARGET_LDFLAGS +=
CONFIGURE_VARS +=
MAKE_FLAGS += \
	libdir=/usr/lib \
	BINTARGETS=efivar

# makeguids is an internal host tool and must be built separately with
# the host CC, otherwise it is cross compiled.
define Build/Compile
	CFLAGS="$(HOST_CFLAGS) -std=gnu99" \
		$(MAKE) -C $(PKG_BUILD_DIR)/src gcc_cflags= makeguids
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/efivar
	$(CP) $(PKG_INSTALL_DIR)/usr/include/efivar/*.h $(1)/usr/include/efivar/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libefi*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/efi*.pc $(1)/usr/lib/pkgconfig/
endef

define Package/efivar/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libefi*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,efivar))
