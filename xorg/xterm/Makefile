# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=xterm
PKG_VERSION:=344
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://invisible-mirror.net/archives/xterm/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_HASH:=ccceb8f6119ae24ab422d7ce7c5713114d304c856daf0d922efc198b56accdf5

#PKG_BUILD_DEPENDS:=
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/xterm
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+libx11 +libice +libxt +libxmu +libxaw +libxpm +libxinerama +libncursesw \
	+libfreetype +fontconfig +libxft
  TITLE:=X.Org console program
  URL:=http://xorg.freedesktop.org/
endef

export TERMINFO=/usr/share/terminfo

CONFIGURE_ARGS += \
  --prefix=/usr \
  --enable-trace \
  --with-x \
  --enable-env-terminfo \
  --enable-builtin-xpms \
  --enable-exec-xterm \
  --disable-i18n \
  --enable-logging \
  --disable-initial-erase \
  --enable-mini-luit \
  --with-app-defaults=/etc/X11/app-defaults

define Package/xterm/install
	$(INSTALL_DIR) \
	  $(1)/usr/bin \
	  $(1)/etc/X11 \
	  $(1)/usr/share/pixmaps

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/bin/* \
	  $(1)/usr/bin/
	$(CP) \
	  $(PKG_INSTALL_DIR)/etc/X11 \
	  $(1)/etc/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/share/pixmaps \
	  $(1)/usr/share/
endef

$(eval $(call BuildPackage,xterm))
