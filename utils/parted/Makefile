# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=parted
PKG_VERSION:=3.6
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://ftp.gnu.org/gnu/parted/
PKG_HASH:=3b43dbe33cca0f9a18601ebab56b7852b128ec1a3df3a9b30ccde5e73359e612

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:parted_project:parted
PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>

PKG_CONFIG_DEPENDS:= \
	CONFIG_PARTED_LVM2 \
	CONFIG_PARTED_READLINE

include $(INCLUDE_DIR)/package.mk

define Package/libparted
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=GNU Parted library
  DEPENDS:=+libblkid +libuuid +PARTED_LVM2:libdevmapper
endef

define Package/libparted/description
  GNU Parted shared library
endef

define Package/parted
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=GNU Parted
  SUBMENU:=Disc
  DEPENDS:=+libparted +PARTED_READLINE:libreadline +PARTED_READLINE:libncurses
endef

define Package/parted/description
  GNU Parted manipulates partition tables. This is useful for
  creating space for new operating systems, reorganizing
  disk usage, copying data on hard disks and disk imaging.
endef

define Package/parted/config
  source "$(SOURCE)/Config.in"
endef

CONFIGURE_ARGS += \
	$(if $(CONFIG_PARTED_READLINE),--with-readline,--without-readline) \
	$(if $(CONFIG_PARTED_LVM2),--enable-device-mapper,--disable-device-mapper)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/parted $(1)/usr/lib/ $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so** $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/parted/*.h $(1)/usr/include/parted/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libparted/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so** $(1)/usr/lib/
endef

define Package/parted/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/parted $(1)/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/partprobe $(1)/sbin/
endef

$(eval $(call BuildPackage,libparted))
$(eval $(call BuildPackage,parted))
