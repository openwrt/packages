#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=v4l2rtspserver
PKG_VERSION:=0.3.7
PKG_RELEASE:=8

#cannot use codeload as this uses submodules
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/mpromonet/v4l2rtspserver
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=bd677579653df07feb979ea00890657807bacadda5fb60c1827f6b99a6dd766a

PKG_BUILD_FLAGS:=gc-sections lto

LIVE555_VERSION:=2022.10.01
LIVE555_HASH:=429de73061e3fc6901c4d2f0b7562ae3f6233060ca4b5e182fe555d065cbdd45
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
	DEPENDS:=+libstdcpp
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
	-DALSA=OFF \
	-DSTATICSTDCPP=OFF \
	-DLIVE555CFLAGS=" -DSOCKLEN_T=socklen_t -D_LARGEFILE_SOURCE=1 -D_FILE_OFFSET_BITS=64 -DLOCALE_NOT_USED -DNO_SSTREAM=1 -DALLOW_RTSP_SERVER_PORT_REUSE=1 -DNO_OPENSSL"

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
