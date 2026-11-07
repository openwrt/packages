#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gst1-rtsp-server
PKG_VERSION:=1.28.7
PKG_RELEASE:=1

PKG_SOURCE:=gst-rtsp-server-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://gstreamer.freedesktop.org/src/gst-rtsp-server
PKG_HASH:=de43a59a0c89a14eb1c14ae8e81e5b45c4e9d7b1f930b0ebaad360f9b5e0b5c4
PKG_BUILD_DIR:=$(BUILD_DIR)/gst-rtsp-server-$(PKG_VERSION)

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=LGPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING COPYING.LIB

GST_VERSION:=1.0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

define Package/gst1-rtsp-server/Default
  SECTION:=multimedia
  CATEGORY:=Multimedia
  URL:=https://gstreamer.freedesktop.org/modules/gst-rtsp-server.html
endef

define Package/libgst1rtspserver
  $(call Package/gst1-rtsp-server/Default)
  TITLE:=GStreamer RTSP server library
  DEPENDS:=+libgstreamer1 +glib2 +libgst1app +libgst1net +libgst1rtp \
	   +libgst1rtsp +libgst1sdp +libgst1video
endef

define Package/libgst1rtspserver/description
  A library to build RTSP servers on top of GStreamer pipelines.
endef

define Package/gst1-mod-rtspclientsink
  $(call Package/gst1-rtsp-server/Default)
  TITLE:=GStreamer RTSP client sink (rtspclientsink)
  DEPENDS:=+libgstreamer1 +libgst1net +libgst1rtp +libgst1rtsp +libgst1sdp \
	   +libgst1rtspserver +gst1-mod-rtpmanager +gst1-mod-rtsp
endef

define Package/gst1-mod-rtspclientsink/description
  The rtspclientsink element, which pushes a stream to an RTSP server.
endef

define Package/gst1-rtsp-launch
  $(call Package/gst1-rtsp-server/Default)
  TITLE:=Serve a GStreamer pipeline over RTSP
  DEPENDS:=+libgst1rtspserver +gstreamer1-plugins-base +gst1-mod-rtp \
	   +gst1-mod-rtpmanager +gst1-mod-unixfd +gst1-mod-videoparsersbad \
	   +ucode +ucode-mod-fs +ucode-mod-uci +ucode-mod-ubus +ucode-mod-uloop \
	   +ucode-mod-socket \
	   +gst1-device-monitor +gstreamer1-utils +v4l-utils
endef

define Package/gst1-rtsp-launch/description
  The test-launch example of gst-rtsp-server. It takes a gst-launch style
  pipeline ending in a payloader named pay0 and serves it at
  rtsp://<host>:8554/test. Includes a procd service configured through UCI,
  using video topology discovery and hardware encoding pipelines.
endef

define Package/gst1-rtsp-launch/conffiles
/etc/config/gst-rtsp
endef

MESON_ARGS += \
	-Dexamples=enabled \
	-Dtests=disabled \
	-Ddoc=disabled \
	-Dintrospection=disabled \
	-Drtspclientsink=enabled \
	-Dglib_debug=disabled \
	-Dglib_assert=false \
	-Dglib_checks=false

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/gstreamer-$(GST_VERSION)
	$(CP) $(PKG_INSTALL_DIR)/usr/include/gstreamer-$(GST_VERSION)/gst \
		$(1)/usr/include/gstreamer-$(GST_VERSION)/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgstrtspserver-$(GST_VERSION).so* \
		$(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/gstreamer-rtsp-server-$(GST_VERSION).pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/libgst1rtspserver/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgstrtspserver-$(GST_VERSION).so.* \
		$(1)/usr/lib/
endef

define Package/gst1-mod-rtspclientsink/install
	$(INSTALL_DIR) $(1)/usr/lib/gstreamer-$(GST_VERSION)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/gstreamer-$(GST_VERSION)/libgstrtspclientsink.so \
		$(1)/usr/lib/gstreamer-$(GST_VERSION)/
endef

define Package/gst1-rtsp-launch/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) $(MESON_BUILD_DIR)/examples/test-launch \
		$(1)/usr/bin/gst-rtsp-launch
	$(INSTALL_BIN) ./files/gst-rtsp.init $(1)/etc/init.d/gst-rtsp
	$(INSTALL_CONF) ./files/gst-rtsp.config $(1)/etc/config/gst-rtsp
	$(INSTALL_DIR) $(1)/usr/share/gst-rtsp \
		$(1)/etc/hotplug.d/video4linux $(1)/etc/hotplug.d/media
	$(INSTALL_DATA) ./files/*.uc $(1)/usr/share/gst-rtsp/
	$(INSTALL_DATA) ./files/gst-rtsp.hotplug $(1)/etc/hotplug.d/video4linux/50-gst-rtsp
	$(INSTALL_DATA) ./files/gst-rtsp.hotplug $(1)/etc/hotplug.d/media/50-gst-rtsp
endef

$(eval $(call BuildPackage,libgst1rtspserver))
$(eval $(call BuildPackage,gst1-mod-rtspclientsink))
$(eval $(call BuildPackage,gst1-rtsp-launch))
