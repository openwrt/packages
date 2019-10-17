#
# Copyright (C) 2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=crtmpserver
PKG_SOURCE_DATE:=2015-10-04
PKG_SOURCE_VERSION:=b866fffca37c3b967a8878499cd2b91aa2587f34
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_DATE).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/shiretu/crtmpserver/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_HASH:=3744bef060129fda6f7902eb64f566b0d5049864dc542b2882c550b083ef82aa
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_SOURCE_VERSION)

PKG_MAINTAINER:=Thomas Heil <heil@terminal-consulting.de>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1
CMAKE_SOURCE_SUBDIR:=builders/cmake
PKG_BUILD_PARALLEL:=0

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/crtmpserver
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS:=$(CXX_DEPENDS) +libopenssl +liblua
  TITLE:=C++ RTMP Server
  URL:=https://github.com/shiretu/crtmpserver
endef

define Package/crtmpserver/description
C++ RTMP Server it is a high performance streaming server able to
stream (live or recorded) in the following technologies:
 * To and from Flash (RTMP,RTMPE, RTMPS, RTMPT, RTMPTE)
 * To and from embedded devices: iPhone, Android
 * From surveillance cameras
 * IP-TV using MPEG-TS and RTSP/RTCP/RTP protocols

Also, crtmpserver can be used as a high performance rendes-vous
server. For example, it enables you to do:
 * Audio/Video conferencing
 * Online gaming
 * Online collaboration
 * Simple/complex chat applications
endef

define Package/crtmpserver/conffiles
/etc/crtmpserver.lua
endef

CMAKE_OPTIONS += \
	-DCRTMPSERVER_INSTALL_PREFIX="$(CMAKE_INSTALL_PREFIX)" \
	-DDL_INCLUDE_PATH="$(TOOLCHAIN_DIR)/include" \
	-DLUA_INCLUDE_PATH_="$(STAGING_DIR)/usr/include" \
	-DLUA_LIBRARY_PATH_="$(STAGING_DIR)/usr/lib/liblua.so" \
	-DOPENSSL_INCLUDE_PATH="$(STAGING_DIR)/usr/include" \

TARGET_CXXFLAGS +=-std=c++11 -ffunction-sections -fdata-sections
TARGET_LDFLAGS +=-Wl,--gc-sections,--as-needed

define Package/crtmpserver/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/crtmpserver $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/lib/crtmpserver
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/crtmpserver/lib* $(1)/usr/lib/crtmpserver
	$(foreach app,flvplayback samplefactory admin stresstest appselector vptests proxypublish, \
		$(INSTALL_DIR) $(1)/usr/lib/crtmpserver/$(app); \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/crtmpserver/applications/$(app)/lib$(app).so \
			$(1)/usr/lib/crtmpserver/$(app)/; \
	)
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/usr/etc/crtmpserver.lua.sample $(1)/etc/
	$(INSTALL_DIR) $(1)/usr/share/crtmpserver/appselector
	$(INSTALL_DIR) $(1)/usr/share/crtmpserver/media
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/crtmpserver.init $(1)/etc/init.d/crtmpserver
endef

$(eval $(call BuildPackage,crtmpserver))

