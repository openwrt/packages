# 
# Copyright (C) 2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=crtmpserver
PKG_REV:=b6fdcdb953d1e99c48a0c37a8c80f2cad2db443b
PKG_VERSION:=2012-07-18+git-$(PKG_REV)
PKG_RELEASE:=2
PKG_BUILD_PARALLEL:=2
PKG_MAINTAINER:=Thomas Heil <heil@terminal-consulting.de>
PKG_LICENSE:=GPL-3.0


PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_MIRROR_HASH:=8d887996b6b8cb465ec59f3f713fca46161cbb804cacd2b5405f836083fb58ba
PKG_SOURCE_URL:=https://github.com/j0sh/crtmpserver.git
PKG_SOURCE_SUBDIR:=crtmpserver-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_PROTO:=git

include $(INCLUDE_DIR)/package.mk

define Package/crtmpserver
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS:=+libopenssl +libstdcpp +liblua
  TITLE:=C++ RTMP Server
  URL:=http://www.rtmpd.com/
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

# XXX: this hack handles the usr/bin vs bin difference of backfire and trunk
TS_BASE:=$(wildcard $(TOOLCHAIN_DIR)/bin/$(TARGET_CC))
TS_BASE:=$(dir $(if $(TS_BASE),$(TS_BASE),$(wildcard $(TOOLCHAIN_DIR)/usr/bin/$(TARGET_CC))))

define Build/Configure
	(cd $(PKG_BUILD_DIR)/builders/make; \
		cp linux.mk linux-openwrt-uclibc.mk; \
		$(SED) 's,^TOOLCHAIN_BASE[[:space:]]*=.*,TOOLCHAIN_BASE=$(TS_BASE),' \
			-e 's,^TOOLCHAIN_PREFIX[[:space:]]*=.*,TOOLCHAIN_PREFIX=$(TARGET_CROSS),' \
			-e 's,^CCOMPILER[[:space:]]*=.*,CCOMPILER=$(TARGET_CC),' \
			-e 's,^CXXCOMPILER[[:space:]]*=.*,CXXCOMPILER=$(TARGET_CXX),' \
			-e 's,^OPTIMIZATIONS[[:space:]]*=.*,OPTIMIZATIONS=-O2,' \
			-e 's,^SSL_BASE[[:space:]]*=.*,SSL_BASE=$(STAGING_DIR)/usr,' \
			linux-openwrt-uclibc.mk)
	(cd $(PKG_BUILD_DIR)/sources/common/include/; \
		echo '#define CRTMPSERVER_VERSION_RELEASE_NUMBER "$(PKG_VERSION)\n"' > version.h; \
		echo '#define CRTMPSERVER_VERSION_CODE_NAME "Git\n"'                >> version.h)
endef

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/builders/make \
		PLATFORM=linux-openwrt-uclibc -Wno-error -j6
endef

define Package/crtmpserver/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/builders/make/output/dynamic/crtmpserver $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/crtmpserver
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/builders/make/output/dynamic/*.so $(1)/usr/lib/crtmpserver/
	$(foreach app,flvplayback samplefactory admin stresstest appselector vptests applestreamingclient proxypublish, \
		$(INSTALL_DIR) $(1)/usr/lib/crtmpserver/$(app); \
		$(INSTALL_BIN) $(PKG_BUILD_DIR)/builders/make/output/dynamic/applications/$(app)/lib$(app).so \
			$(1)/usr/lib/crtmpserver/$(app)/; \
	)
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/builders/make/output/dynamic/crtmpserver.lua $(1)/etc/
	$(INSTALL_DIR) $(1)/usr/share/crtmpserver/appselector
	$(INSTALL_DIR) $(1)/usr/share/crtmpserver/media
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/crtmpserver.init $(1)/etc/init.d/crtmpserver
endef

$(eval $(call BuildPackage,crtmpserver))

