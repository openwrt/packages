# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=font-cursor-misc
PKG_VERSION:=1.0.3
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://www.x.org/releases/individual/font/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=17363eb35eece2e08144da5f060c70103b59d0972b4f4d77fd84c9a7a2dba635

#PKG_BUILD_DIR:=$(BUILD_DIR)/$(_PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=util-macros mkfontscale/host mkfontdir/host bdftopcf/host font-util/host
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/font-cursor-misc
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+encodings +font-alias
  TITLE:=X.org misc font
  URL:=http://xorg.freedesktop.org/
endef

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

CONFIGURE_ARGS += \
  --prefix=/usr \
  --with-fontrootdir=/usr/share/fonts/X11

define Package/font-cursor-misc/install
	$(INSTALL_DIR) \
	  $(1)/usr/share/fonts/X11/misc

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/share/fonts/X11/misc/*.pcf.gz \
	  $(1)/usr/share/fonts/X11/misc/
endef

$(eval $(call BuildPackage,font-cursor-misc))
