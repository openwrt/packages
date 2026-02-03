#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=screen
PKG_VERSION:=5.0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/screen
PKG_HASH:=2dae36f4db379ffcd14b691596ba6ec18ac3a9e22bc47ac239789ab58409869d

PKG_MAINTAINER:=Etienne CHAMPETIER <champetier.etienne@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:gnu:screen

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/screen
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Terminal
  DEPENDS:= +USE_GLIBC:libcrypt-compat +libncurses
  TITLE:=Full-screen terminal window manager
  URL:=https://www.gnu.org/software/screen/
endef

define Package/screen/description
	Screen is a full-screen window manager that multiplexes a physical
	terminal between several processes, typically interactive shells.
endef

CONFIGURE_ARGS += \
	--enable-colors256 \
	--disable-pam \
	--with-sys-screenrc=/etc/screenrc \

define Package/screen/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/screen $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) ./files/etc/screenrc $(1)/etc/screenrc
endef

define Package/screen/conffiles
/etc/screenrc
endef

$(eval $(call BuildPackage,screen))
