#
# Copyright (C) 2011-2020 Entware
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gerbera
PKG_VERSION:=1.4.0
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/gerbera/gerbera/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=904a9031c85ac805e4c139f363510226952683d7257acd1dee25ba1e97fd7651

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE.md

PKG_BUILD_DEPENDS:=libmatroska taglib
PKG_BUILD_PARALLEL:=1
PKG_CONFIG_DEPENDS:=CONFIG_BUILD_PATENTED

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/nls.mk

define Package/gerbera
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS:=+file +libupnp +libsqlite3 +libexif +libexpat +libuuid +BUILD_PATENTED:libffmpeg +libstdcpp $(ICONV_DEPENDS)
  TITLE:=A free media server
  URL:=https://gerbera.io
  USERID:=gerbera:gerbera
endef

define Package/gerbera/description
  Gerbera - UPnP Media Server based on Mediatomb.
endef

define Package/gerbera/conffiles
/etc/gerbera/config
endef

CMAKE_OPTIONS += \
	-DICONV_INCLUDE_DIR=$(ICONV_PREFIX)/include \
	-DICONV_LIBRARIES=$(ICONV_PREFIX)/lib/libiconv.a \
	-DWITH_MAGIC=1 \
	-DWITH_MYSQL=0 \
	-DWITH_CURL=0 \
	-DWITH_INOTIFY=1 \
	-DWITH_JS=0 \
	-DWITH_TAGLIB=1 \
	-DWITH_AVCODEC=$(if $(CONFIG_BUILD_PATENTED),ON,OFF) \
	-DWITH_FFMPEGTHUMBNAILER=0 \
	-DWITH_EXIF=1 \
	-DWITH_EXIV2=0 \
	-DWITH_MATROSKA=1 \
	-DWITH_SYSTEMD=0 \
	-DWITH_LASTFM=0 \
	-DWITH_DEBUG=0 \
	-DWITH_TESTS=0

TARGET_CFLAGS += -ffunction-sections -fdata-sections -flto
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
