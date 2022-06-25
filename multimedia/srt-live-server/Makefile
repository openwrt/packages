#
# Copyright (C) 2022 Han Han
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=srt-live-server
PKG_VERSION:=1.4.8
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Edward-Wu/$(PKG_NAME)/archive/refs/tags/V$(PKG_VERSION).tar.gz?
PKG_HASH:=3526a65e1d581b9ec62627d733d62a90dc074ae830e9bd7abe3f3b0a152b2786

PKG_MAINTAINER:=Han Han <hanhanzhiyeqianke@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/srt-live-server
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=srt-live-server(SLS) is an open source live streaming server
  URL:=https://github.com/Edward-Wu/srt-live-server
  DEPENDS:=+libsrt +zlib
endef

define Package/srt-live-server/description
  srt-live-server(SLS) is an open source live streaming server for low latency based on
  Secure Reliable Transport(SRT). Normally, the latency of transport by SLS is less than
  1 second in internet.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
			CXX="$(TARGET_CXX)" \
			CXXFLAGS="$(TARGET_CXXFLAGS)" \
			LDFLAGS="$(TARGET_LDFLAGS)"
endef

define Package/srt-live-server/install
  $(INSTALL_DIR) $(1)/usr/bin
  $(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/* $(1)/usr/bin
  $(INSTALL_DIR) $(1)/etc/srt-live-server
  $(INSTALL_DATA) $(PKG_INSTALL_DIR)/sls.conf $(1)/etc/srt-live-server/sls.conf
endef

$(eval $(call BuildPackage,srt-live-server))
