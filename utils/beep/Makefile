#
# Copyright (C) 2017 Chris Blake (chrisrblake93@gmail.com)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=beep
PKG_VERSION:=1.4.12
PKG_RELEASE:=6

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/spkr-beep/beep/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=6188d0f0c180db7a30467b5b6065a3cb5d2665b937d2e8c40366efb52bf689fe

include $(INCLUDE_DIR)/package.mk

define Package/beep
  SECTION:=sound
  CATEGORY:=Sound
  DEPENDS:=+TARGET_x86:kmod-pcspkr @!TARGET_x86:kmod-gpio-beeper
  TITLE:=Play beep sounds through a PC speaker
  URL:=https://github.com/spkr-beep/beep
endef

define Package/beep/description
  This program plays beeps through the PC speaker
endef

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)"

define Package/beep/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/beep $(1)/usr/bin
endef

$(eval $(call BuildPackage,beep))
