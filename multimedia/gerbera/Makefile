#
# Copyright (C) 2011-2020 Entware
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gerbera
PKG_VERSION:=1.6.4
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/gerbera/gerbera/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=cbe7ea78977db8c02fcca1759ed149f199a590afaf4a6d21ffcca8623d1a0cc5

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE.md

PKG_BUILD_DEPENDS:=libmatroska pugixml spdlog taglib
PKG_BUILD_PARALLEL:=1
PKG_CONFIG_DEPENDS:=CONFIG_BUILD_PATENTED

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/nls.mk

define Package/gerbera
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS:=+file +libnpupnp +libsqlite3 +libexif +libuuid +libfmt +BUILD_PATENTED:libffmpeg $(ICONV_DEPENDS)
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

CMAKE_OPTIONS += \
	-DIconv_INCLUDE_DIR=$(ICONV_PREFIX)/include \
	-DIconv_LIBRARY=$(ICONV_PREFIX)/lib/libiconv.a \
	-DWITH_MAGIC=ON \
	-DWITH_MYSQL=OFF \
	-DWITH_CURL=ON \
	-DWITH_INOTIFY=ON \
	-DWITH_JS=OFF \
	-DWITH_TAGLIB=ON \
	-DWITH_AVCODEC=$(if $(CONFIG_BUILD_PATENTED),ON,OFF) \
	-DWITH_FFMPEGTHUMBNAILER=OFF \
	-DWITH_EXIF=ON \
	-DWITH_EXIV2=OFF \
	-DWITH_MATROSKA=ON \
	-DWITH_SYSTEMD=OFF \
	-DWITH_LASTFM=OFF \
	-DWITH_DEBUG=OFF \
	-DWITH_TESTS=OFF \
	-DWITH_NPUPNP=ON

TARGET_CFLAGS += \
	-ffunction-sections \
	-fdata-sections \
	-flto

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

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
