#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gst1-libav
PKG_VERSION:=1.26.10
PKG_RELEASE:=1

PKG_SOURCE:=gst-libav-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://gstreamer.freedesktop.org/src/gst-libav
PKG_HASH:=c8c2fd29cc063a6d26c314cd1a0a3a3060c8a029981b9520fab52c4206d11611
PKG_BUILD_DIR:=$(BUILD_DIR)/gst-libav-$(PKG_VERSION)

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org> \
		Ted Hess <thess@kitschensync.net>
PKG_LICENSE:=GPL-2.0-or-later LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING COPYING.LIB

PKG_BUILD_FLAGS:=no-mips16

GST_VERSION:=1.0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

define Package/gst1-libav
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=GStreamer Libav plugin
  URL:=https://www.gstreamer.net/modules/gst-libav.html
  DEPENDS:= +libgstreamer1 +gstreamer1-plugins-base \
	    +gst1-mod-alsa +libgst1audio +libgst1pbutils +libgst1video \
	    +libbz2 +liblzma +libffmpeg-full
endef

define Package/gst1-libav/description
  GStreamer with libav bindings using internal Libav
endef

define Package/gst1-libav/install
	$(INSTALL_DIR) $(1)/usr/lib/gstreamer-$(GST_VERSION)
	( cd $(PKG_INSTALL_DIR); $(CP) \
		./usr/lib/gstreamer-$(GST_VERSION)/libgstlibav.so* \
		$(1)/usr/lib/gstreamer-$(GST_VERSION)/ \
	)
endef

$(eval $(call BuildPackage,gst1-libav))
