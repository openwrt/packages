#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mjpg-streamer
PKG_VERSION:=2018-10-25
PKG_RELEASE:=2
PKG_MAINTAINER:=Roger D <rogerdammit@gmail.com>, \
		Ted Hess <thess@kitschensync.net>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/jacksonliam/mjpg-streamer.git
PKG_SOURCE_VERSION:=ddb69b7b4f114f3c2ca01adf55712792ca8aed43
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_MIRROR_HASH:=d87ebff5de0c17a35a5b81adad5aa234bc70fe2bb17d1c6277c726845dc043bb

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

PKG_BUILD_DEPENDS:=MJPG_STREAMER_V4L2:libv4l

define Package/mjpg-streamer
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=MJPG-streamer
  DEPENDS:=+libpthread +libjpeg +MJPG_STREAMER_V4L2:libv4l
  URL:=https://github.com/jacksonliam/mjpg-streamer
  MENU:=1
endef

define Package/mjpg-streamer/description
 Streaming application for Linux-UVC compatible webcams
endef

define Package/mjpg-streamer/config
  source "$(SOURCE)/Config.in"
endef

define Package/mjpg-streamer/conffiles
/etc/config/mjpg-streamer
endef

CAMBOZOLA:=cambozola-0.936.tar.gz

# Distribution URL doesn't always have the correct version
# Using the OpenWrt mirror provides a stable version
#      orig-URL:=http://www.andywilcock.com/code/cambozola
define Download/cambozola
  URL:=https://sources.openwrt.org/
  FILE:=$(CAMBOZOLA)
  HASH:=4e4e92d95673edd051e6b4d36bed8c5328873f5fc374073760b457d4be33415b
endef

# redefine prepare to extract to our build dir
# apply patches
define Build/Prepare
	rm -rf $(PKG_BUILD_DIR)/
	mkdir -p $(PKG_BUILD_DIR)/
	$(TAR) -xJf $(DL_DIR)/$(PKG_SOURCE) -C $(PKG_BUILD_DIR) --strip=2
	$(Build/Patch)
    # Fetch latest cambozola that works with latest Java(s)
    # Yes, I know this is ugly
    ifeq ($(CONFIG_MJPG_STREAMER_WWW),y)
	$(eval $(call Download,cambozola))
	$(TAR) -xf $(DL_DIR)/$(CAMBOZOLA) --strip=2 --wildcards \
		-C $(PKG_BUILD_DIR)/www */dist/cambozola.jar
    endif
endef

define Build/Configure
    $(RM) $(PKG_BUILD_DIR)/plugins/input_uvc/uvcvideo.h
endef

    TARGET_LDFLAGS+= -ljpeg

ifeq ($(CONFIG_MJPG_STREAMER_V4L2),y)
    TARGET_CFLAGS+= -DUSE_LIBV4L2
    TARGET_LDFLAGS+= -lv4l2
endif

define Package/mjpg-streamer/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mjpg_streamer $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config
	$(CP) ./files/mjpg-streamer.config $(1)/etc/config/mjpg-streamer
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mjpg-streamer.init $(1)/etc/init.d/mjpg-streamer
	$(INSTALL_DIR) $(1)/etc/hotplug.d/usb
	$(INSTALL_DATA) ./files/mjpg-streamer.hotplug $(1)/etc/hotplug.d/usb/20-mjpg-streamer
	$(INSTALL_DIR) $(1)/usr/lib
ifeq ($(CONFIG_MJPG_STREAMER_INPUT_FILE),y)
	$(CP) $(PKG_BUILD_DIR)/input_file.so $(1)/usr/lib
endif
ifeq ($(CONFIG_MJPG_STREAMER_INPUT_UVC),y)
	$(CP) $(PKG_BUILD_DIR)/input_uvc.so $(1)/usr/lib
endif
ifeq ($(CONFIG_MJPG_STREAMER_INPUT_HTTP),y)
	$(CP) $(PKG_BUILD_DIR)/input_http.so $(1)/usr/lib
endif
ifeq ($(CONFIG_MJPG_STREAMER_OUTPUT_RTSP),y)
	$(CP) $(PKG_BUILD_DIR)/output_rtsp.so $(1)/usr/lib
endif
ifeq ($(CONFIG_MJPG_STREAMER_OUTPUT_UDP),y)
	$(CP) $(PKG_BUILD_DIR)/output_udp.so $(1)/usr/lib
endif
ifeq ($(CONFIG_MJPG_STREAMER_OUTPUT_FILE),y)
	$(CP) $(PKG_BUILD_DIR)/output_file.so $(1)/usr/lib
endif
ifeq ($(CONFIG_MJPG_STREAMER_OUTPUT_HTTP),y)
	$(CP) $(PKG_BUILD_DIR)/output_http.so $(1)/usr/lib
	$(INSTALL_DIR) $(1)/www/webcam
    ifeq ($(CONFIG_MJPG_STREAMER_WWW),y)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/www/* $(1)/www/webcam
    else
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/www/stream_simple.html $(1)/www/webcam/index.html
    endif
endif
endef

$(eval $(call BuildPackage,mjpg-streamer))
