#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=beep
PKG_REV:=0d790fa45777896749a885c3b93b2c1476d59f20
PKG_VERSION:=1.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/johnath/beep.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)

PKG_LICENSE:=GPL
PKG_LICENSE_FILES:=

include $(INCLUDE_DIR)/package.mk

define Package/beep
  SECTION:=sound
  CATEGORY:=Sound
  DEPENDS:=+kmod-pcspkr
  TITLE:=Play beep sounds through a PC speaker
  URL:=http://johnath.com/beep/README
endef

define Package/beep/description
	This program plays beeps through the PC speaker
endef

CONFIGURE_ARGS += \
	--enable-static \
	--enable-shared

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)"

define Package/beep/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/beep $(1)/usr/bin
endef

$(eval $(call BuildPackage,beep))
