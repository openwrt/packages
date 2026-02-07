#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ustreamer
PKG_VERSION:=6.52
PKG_RELEASE:=1
PKG_MAINTAINER:=Georgi Valkov <gvalkov@gmail.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/pikvm/ustreamer/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=db00adfa02acfbdf6682ffae8e418b582d623e1971672d5df19858e02e2f3b0e

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

MAKE_FLAGS += WITH_SETPROCTITLE=0

define Package/ustreamer
	SECTION:=multimedia
	CATEGORY:=Multimedia
	TITLE:=Lightweight and fast MJPEG-HTTP streamer
	DEPENDS:=+libatomic +libjpeg +libevent2 +libevent2-pthreads
	URL:=https://github.com/pikvm/ustreamer
endef

define Package/ustreamer/description
uStreamer is a lightweight and very quick server to stream MJPEG video
from any V4L2 device to the net. All new browsers have native support
of this video format, as well as most video players such as mplayer,
VLC etc. uStreamer is a part of the PiKVM project designed to stream
VGA and HDMI screencast hardware data with the highest resolution and
FPS possible.
endef

define Package/ustreamer/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ustreamer $(1)/usr/bin/ustreamer
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ustreamer-dump $(1)/usr/bin/ustreamer-dump
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/ustreamer.config $(1)/etc/config/ustreamer
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ustreamer.init $(1)/etc/init.d/ustreamer
	$(INSTALL_DIR) $(1)/etc/hotplug.d/usb
	$(INSTALL_DATA) ./files/ustreamer.hotplug $(1)/etc/hotplug.d/usb/20-ustreamer
endef

$(eval $(call BuildPackage,ustreamer))
