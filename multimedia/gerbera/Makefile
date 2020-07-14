#
# Copyright (C) 2011-2020 Entware
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gerbera
PKG_VERSION:=1.5.0
PKG_RELEASE:=9

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/gerbera/gerbera/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=693a99b295bc79d842f036a6d04996d4676ac0791d65f3a1f7aab4badf9fb5ef

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE.md

PKG_BUILD_DEPENDS:=libmatroska pugixml spdlog taglib
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/nls.mk

define Package/gerbera
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS:=+file +libnpupnp +libsqlite3 +libexif +libuuid +libfmt $(ICONV_DEPENDS)
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
	-DCXX_FILESYSTEM_NO_LINK_NEEDED=$(if $(CONFIG_GCC_USE_VERSION_9),ON,OFF) \
	-DCXX_FILESYSTEM_STDCPPFS_NEEDED=$(if $(CONFIG_GCC_USE_VERSION_8),OFF,ON) \
	-DICONV_INCLUDE_DIR=$(ICONV_PREFIX)/include \
	-DICONV_LIBRARIES=$(ICONV_PREFIX)/lib/libiconv.a \
	-DWITH_MAGIC=ON \
	-DWITH_MYSQL=OFF \
	-DWITH_CURL=OFF \
	-DWITH_INOTIFY=ON \
	-DWITH_JS=OFF \
	-DWITH_TAGLIB=ON \
	-DWITH_AVCODEC=OFF \
	-DWITH_FFMPEGTHUMBNAILER=OFF \
	-DWITH_EXIF=ON \
	-DWITH_EXIV2=OFF \
	-DWITH_MATROSKA=ON \
	-DWITH_SYSTEMD=OFF \
	-DWITH_LASTFM=OFF \
	-DWITH_DEBUG=OFF \
	-DWITH_TESTS=OFF

TARGET_CFLAGS += \
	-ffunction-sections \
	-fdata-sections \
	-flto \
	-I$(STAGING_DIR)/usr/include/npupnp/upnp
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
