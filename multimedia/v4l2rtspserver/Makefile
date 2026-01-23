#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=v4l2rtspserver
PKG_VERSION:=0.3.12
PKG_RELEASE:=1

#cannot use codeload as this uses submodules
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/mpromonet/v4l2rtspserver
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=445facb458ed6f59c319246e8244f8353ab64f053e08e56380edc1aed0806a7d

PKG_BUILD_FLAGS:=gc-sections lto

LIVE555_VERSION:=2024.08.01
LIVE555_HASH:=839ab7437d01e629f8094ea1ec8c7a7bb504c7deed9edfc9e17ac34f9a1a193f
LIVE555_FILE:=live.$(LIVE555_VERSION).tar.gz

PKG_MAINTAINER:=Roger Dammit <rogerdammit@gmail.com>
PKG_LICENSE:=Unlicense
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/v4l2rtspserver
	SECTION:=multimedia
	CATEGORY:=Multimedia
	TITLE:=v4l2rtspserver
	DEPENDS:=+libstdcpp +alsa-lib
	URL:=https://github.com/mpromonet/v4l2rtspserver
endef

define Package/v4l2rtspserver/description
	RTSP server for v4L2 video sources
endef

define Package/v4l2rtspserver/conffiles
/etc/config/v4l2rtspserver
endef

define Download/live555
	URL:=https://download.videolan.org/pub/contrib/live555/
	FILE:=$(LIVE555_FILE)
	HASH:=$(LIVE555_HASH)
endef

TARGET_LDFLAGS += -Wl,--as-needed

CMAKE_OPTIONS += \
	-DSTATICSTDCPP=OFF \
	-DWITH_SSL=OFF \
	-DLIVE555CFLAGS="SOCKLEN_T=socklen_t;_LARGEFILE_SOURCE=1;_FILE_OFFSET_BITS=64;LOCALE_NOT_USED;NO_SSTREAM=1;ALLOW_RTSP_SERVER_PORT_REUSE=1;NO_STD_LIB=1;VERSION=\"$(PKG_VERSION)\""


define Build/Prepare
	# download live555
	$(eval $(call Download,live555))
	mkdir -p $(PKG_BUILD_DIR)/live
	$(TAR) -xf $(DL_DIR)/$(LIVE555_FILE) --strip=1 -C $(PKG_BUILD_DIR)/live
	$(Build/Prepare/Default)
endef

define Package/v4l2rtspserver/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/v4l2rtspserver $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/v4l2rtspserver.init $(1)/etc/init.d/v4l2rtspserver
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/v4l2rtspserver.config $(1)/etc/config/v4l2rtspserver
endef

$(eval $(call BuildPackage,v4l2rtspserver))
