# This software is in the public domain, furnished "as is", without technical
# support, and with no warranty, express or implied, as to its usefulness for
# any purpose.

include $(TOPDIR)/rules.mk

PKG_NAME:=v4l2camera
PKG_VERSION:=0.2.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/mpromonet/v4l2camera
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=d35223631dbbe78107d807ee0de78abe1214b67df85d0140ef28c12176c924cc

UI_FILE:=v4l2camera-ui-$(PKG_VERSION).tgz
UI_HASH:=147eceba82478c53f0de0fe1c705be1025151d36a0b8f969e238267b42f5c223

LIVE555_VERSION:=2023.01.19
LIVE555_HASH:=a7c64913f7f7007c5fdc29ea811e3ca781f262271b3e42afdd4bc1041d86fa99
LIVE555_FILE:=live.$(LIVE555_VERSION).tar.gz

PKG_MAINTAINER:=Michel Promonet<michel.promonet@free.fr>
PKG_LICENSE:=Unlicense
PKG_LICENSE_FILES:=LICENCE

PKG_BUILD_FLAGS:=gc-sections lto

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

RSTRIP:=:

define Package/v4l2camera
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=v4l2camera
  DEPENDS:=+libstdcpp +alsa-lib
  URL:=https://github.com/mpromonet/v4l2camera
endef

define Package/v4l2camera/conffiles
/etc/config/v4l2camera
endef

CMAKE_OPTIONS += \
       -DWITH_SSL=OFF \
       -DWITH_COMPRESS=OFF \
       -DBUILD_UI=OFF

define Download/live555
	URL:=https://download.videolan.org/pub/contrib/live555/
	FILE:=$(LIVE555_FILE)
	HASH:=$(LIVE555_HASH)
endef

define Download/ui
	URL:=https://registry.npmjs.org/v4l2camera-ui/-/
	FILE:=$(UI_FILE)
	HASH:=$(UI_HASH)
endef

TARGET_LDFLAGS += -lasound

define Build/Prepare
	# download live555
	$(eval $(call Download,live555))
	mkdir -p $(PKG_BUILD_DIR)/live
	$(TAR) -xf $(DL_DIR)/$(LIVE555_FILE) --strip=1 -C $(PKG_BUILD_DIR)/live

	# download ui
	$(eval $(call Download,ui))
	mkdir -p $(PKG_BUILD_DIR)/vuejs
	$(TAR) -xf $(DL_DIR)/$(UI_FILE) --strip=1 -C $(PKG_BUILD_DIR)/vuejs

	$(Build/Prepare/Default)
endef

define Package/v4l2camera/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/v4l2camera $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/usr/share/v4l2camera
	$(CP) $(PKG_INSTALL_DIR)/usr/share/v4l2camera $(1)/usr/share/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/v4l2camera.init $(1)/etc/init.d/v4l2camera
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/v4l2camera.config $(1)/etc/config/v4l2camera
endef

$(eval $(call BuildPackage,v4l2camera))
