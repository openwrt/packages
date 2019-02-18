#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=v4l2rtspserver
PKG_VERSION:=0.1.3
PKG_RELEASE:=1

#cannot use codeload as this uses submodules
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/mpromonet/v4l2rtspserver
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=73499d0db515ae0d66c6d2a73c9c474ca35007aaf17451da01e793d972eab35a

PKG_MAINTAINER:=Roger Dammit <rogerdammit@gmail.com>
PKG_LICENSE:=Unlicense
PKG_LICENSE_FILES:=LICENSE

LIVE555_VERSION:=2019.02.03
LIVE555_HASH:=1c938d91553eff224c7a860f8f38b3256028704b474a3fc6bcf2eddc42268710
LIVE555_FILE:=live.$(LIVE555_VERSION).tar.gz

PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/v4l2rtspserver
	SECTION:=multimedia
	CATEGORY:=Multimedia
	TITLE:=v4l2rtspserver
	DEPENDS:=$(CXX_DEPENDS)
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

TARGET_CFLAGS += -flto
TARGET_CXXFLAGS += -fno-rtti
TARGET_LDFLAGS += -Wl,--gc-sections

define Build/Prepare
	$(Build/Prepare/Default)

	## need to compile some dependencies so that cmake will find them

	# build live555
	$(eval $(call Download,live555))

	mkdir -p $(PKG_BUILD_DIR)/live555
	$(TAR) -xf $(DL_DIR)/$(LIVE555_FILE) --strip=1 -C $(PKG_BUILD_DIR)/live555
	$(CP) files/config.openwrt $(PKG_BUILD_DIR)/live555
	( cd $(PKG_BUILD_DIR)/live555; ./genMakefiles openwrt )

	+$(MAKE_VARS) $(MAKE) $(MAKE_FLAGS) -C $(PKG_BUILD_DIR)/live555
	 $(MAKE_VARS) $(MAKE) $(MAKE_FLAGS) -C $(PKG_BUILD_DIR)/live555 PREFIX="$(STAGING_DIR)/usr/" install

	# build v4l2wrapper
	+$(MAKE_VARS) $(MAKE) $(MAKE_FLAGS) -C $(PKG_BUILD_DIR)/v4l2wrapper
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
