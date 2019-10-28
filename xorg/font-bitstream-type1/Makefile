# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=font-bitstream-type1
PKG_VERSION:=1.0.3
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://www.x.org/releases/individual/font/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=c6ea0569adad2c577f140328dc3302e729cb1b1ea90cd0025caf380625f8a688

PKG_BUILD_DEPENDS:=font-util font-util/host util-macros bdftopcf/host mkfontscale/host mkfontdir/host
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/font-bitstream-type1
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+encodings +font-alias +fontconfig
  TITLE:=X.org bitstream Type1 fonts
  URL:=http://xorg.freedesktop.org/
endef

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

CONFIGURE_ARGS += \
  --prefix=/usr \
  --with-mapfiles=/usr/share/fonts/util \
  --with-fontdir=/usr/share/fonts/Type1

##  --with-fontrootdir=$(STAGING_DIR)/usr/share/fonts/X11
###  =$(STAGING_DIR)/usr/share/fonts/X11/util


define Package/font-bitstream-type1/install
	$(INSTALL_DIR) \
	  $(1)/usr/share/fonts

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/share/fonts/Type1 \
	  $(1)/usr/share/fonts/
endef

$(eval $(call BuildPackage,font-bitstream-type1))
