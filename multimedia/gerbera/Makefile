#
# Copyright (C) 2011-2020 Entware
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gerbera
PKG_VERSION:=1.11.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/gerbera/gerbera/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=0c13049792a28ec0e3086ba61c7f9675626a1dbadb043650a452192727418be7

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE.md

PKG_BUILD_DEPENDS:=libmatroska pugixml spdlog
PKG_CONFIG_DEPENDS:=CONFIG_BUILD_PATENTED

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

define Package/gerbera
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS:=+file +libnpupnp +libsqlite3 +libexif +libuuid +libfmt +libatomic +taglib +BUILD_PATENTED:libffmpeg $(ICONV_DEPENDS)
  TITLE:=A free media server
  URL:=https://gerbera.io
  USERID:=gerbera:gerbera
endef

define Package/gerbera/description
  Gerbera - UPnP Media Server based on Mediatomb.
endef

define Package/gerbera/conffiles
/etc/config/gerbera
endef

MESON_ARGS += \
	-Db_lto=true \
	-Davcodec=$(if $(CONFIG_BUILD_PATENTED),en,dis)abled \
	-Dcurl=enabled \
	-Dexif=enabled \
	-Dexiv2=disabled \
	-Dffmpegthumbnailer=disabled \
	-Dinotify=enabled \
	-Djs=disabled \
	-Dlastfm=disabled \
	-Dmagic=enabled \
	-Dmatroska=enabled \
	-Dmysql=disabled \
	-Dnpupnp=enabled \
	-Dsystemd=disabled \
	-Dtaglib=enabled \
	-Dtests=disabled \
	-Dwavpack=disabled

TARGET_CFLAGS += \
	-ffunction-sections \
	-fdata-sections

TARGET_LDFLAGS += -Wl,--gc-sections

define Package/gerbera/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gerbera $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/share
	$(CP) $(PKG_INSTALL_DIR)/usr/share/gerbera $(1)/usr/share
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/gerbera.config $(1)/etc/config/gerbera
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/gerbera.init $(1)/etc/init.d/gerbera
endef

$(eval $(call BuildPackage,gerbera))
