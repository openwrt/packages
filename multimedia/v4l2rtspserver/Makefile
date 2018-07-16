#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=v4l2rtspserver
PKG_VERSION:=0.0.8
PKG_RELEASE:=1
PKG_MAINTAINER:=Roger Dammit <rogerdammit@gmail.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/mpromonet/v4l2rtspserver/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=bb4f82ca916b78cbcaeb4093c4bcded3ed89c79568ee4214c9d5a4d654c7f78e

LIVE555_VERSION:=2018.04.25
LIVE555_MD5SUM:=9b58a5d62659eb29b9bd85d1b29c3a75
LIVE555_FILE:=live.$(LIVE555_VERSION).tar.gz

CMAKE_INSTALL:=1

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
	MD5SUM:=$(LIVE555_MD5SUM)
endef

define Build/Prepare
	$(Build/Prepare/Default)

	## need to compile some dependencies so that cmake will find them

	# build live555
        $(eval $(call Download,live555))

	mkdir -p $(PKG_BUILD_DIR)/live555
	$(TAR) -xf $(DL_DIR)/$(LIVE555_FILE) --strip=1 -C $(PKG_BUILD_DIR)/live555
	$(CP) files/config.openwrt $(PKG_BUILD_DIR)/live555
	( cd $(PKG_BUILD_DIR)/live555; ./genMakefiles openwrt )

	$(MAKE) $(MAKE_FLAGS) -C $(PKG_BUILD_DIR)/live555
	$(MAKE) -C $(PKG_BUILD_DIR)/live555 PREFIX="$(STAGING_DIR)/usr/" install

	# build v4l2wrapper
	$(MAKE) $(MAKE_FLAGS) -C $(PKG_BUILD_DIR)/v4l2wrapper CFLAGS="$(TARGET_CFLAGS) -I $(PKG_BUILD_DIR)/v4l2wrapper/inc"
	$(CP) $(PKG_BUILD_DIR)/v4l2wrapper/libv4l2wrapper.a $(PKG_BUILD_DIR)

	# cmake patches (these are very hacky and should be a lot cleaner)

	# prevent root path override 
	$(SED) 's/SET(CMAKE_FIND_ROOT_PATH/#SET(CMAKE_FIND_ROOT_PATH/' $(PKG_BUILD_DIR)/CMakeLists.txt

	# set search path for v4l2wrapper to current build dir
	$(SED) 's/V4L2WRAPPER_LIBRARY libv4l2wrapper.a/V4L2WRAPPER_LIBRARY libv4l2wrapper.a PATHS "." NO_CMAKE_FIND_ROOT_PATH/' $(PKG_BUILD_DIR)/CMakeLists.txt

	# disable ALSA
	$(SED) 's/find_package(ALSA QUIET)//' $(PKG_BUILD_DIR)/CMakeLists.txt
endef

define Package/v4l2rtspserver/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/v4l2rtspserver-$(PKG_VERSION) $(1)/usr/bin/
	mv $(1)/usr/bin/v4l2rtspserver-$(PKG_VERSION) $(1)/usr/bin/v4l2rtspserver

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/v4l2rtspserver.init $(1)/etc/init.d/v4l2rtspserver
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/v4l2rtspserver.config $(1)/etc/config/v4l2rtspserver
endef

$(eval $(call BuildPackage,v4l2rtspserver))
