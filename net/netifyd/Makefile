# Netify Agent
# Copyright (C) 2016-2018 eGloo, Incorporated
#
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

# Name, version and release number
# The name and version of your package are used to define the variable to point to the build directory of your package: $(PKG_BUILD_DIR)
PKG_NAME:=netifyd
PKG_VERSION:=2.67
PKG_RELEASE:=1
PKG_MAINTAINER:=Darryl Sokoloski <darryl@egloo.ca>
PKG_LICENSE:=GPL-3.0+

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_CONFIG_DEPENDS:=CONFIG_LIBCURL_ZLIB

# Source settings

# Disable the following and enable SOURCE_DIR below for local test builds.
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://bitbucket.org/eglooca/netify-daemon.git
PKG_SOURCE_DATE:=2018-07-03
PKG_SOURCE_VERSION:=242234f856acebe9ddfd4b3311be63709c01eb08
PKG_MIRROR_HASH:=f05a608d61b5b72e4564d9f124d724d7a0afa207d5e05fff8e235c199f814a05

# Local source builds (create symlink to source here)
#SOURCE_DIR:=$(TOPDIR)/netify-daemon

#include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

# Package definition
define Package/netifyd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Netify Agent
  URL:=http://www.netify.ai/
  DEPENDS:=+libcurl +libmnl +libnetfilter-conntrack +libjson-c +libpcap +zlib +libpthread +uclibcxx +libstdcpp
endef

# Package description
define Package/netifyd/description
Netify provides visibility into the traffic on your network along with the
option to take an active role (on supported devices) in blocking or shaping
undesirable traffic from recurring on your network.

endef

# Package configuration
define Package/netifyd/conffiles
#/etc/config/netifyd
/etc/netifyd.conf
endef

# Compiler, linker, and make options
COPTS =

TARGET_CFLAGS += -ffunction-sections -fdata-sections
TARGET_CXXFLAGS += -ffunction-sections -fdata-sections
TARGET_LDFLAGS += -Wl,--gc-sections

CONFIGURE_VARS += \
	LIBCURL_CFLAGS="-I $(STAGING_DIR)/usr/include" \
	LIBCURL_LDFLAGS="-L $(STAGING_DIR)/usr/lib" \
	LIBMNL_CFLAGS="-I $(STAGING_DIR)/usr/include" \
	LIBMNL_LDFLAGS="-L $(STAGING_DIR)/usr/lib" \
	LIBNETFILTER_CONNTRACK_CFLAGS="-I $(STAGING_DIR)/usr/include" \
	LIBNETFILTER_CONNTRACK_LDFLAGS="-L $(STAGING_DIR)/usr/lib"

# Package preparation
#define Build/Prepare
#	mkdir -p $(PKG_BUILD_DIR)
#	cp -a $(SOURCE_DIR)/. $(PKG_BUILD_DIR)/
#	$(Build/Patch)
#endef

# Package configure

CONFIGURE_ARGS += \
	--sharedstatedir=/var/lib \
	--disable-inotify \
	--disable-ncurses \
	--disable-libtcmalloc \
	--without-systemdsystemunitdir

define Build/Configure
	(cd $(PKG_BUILD_DIR); ./autogen.sh)
	$(call Build/Configure/Default,$CONFIGURE_ARGS)
endef

# Package install
define Package/netifyd/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/deploy/netifyd.conf $(1)/etc
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/netifyd.init $(1)/etc/init.d/netifyd
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/netifyd $(1)/usr/sbin
	#$(INSTALL_DIR) $(1)/etc/config
	#$(INSTALL_DIR) $(1)/var/lib/netifyd
	$(INSTALL_DIR) $(1)/etc/netify.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/deploy/app-custom-match.conf $(1)/etc/netify.d/netify-sink.conf
	$(INSTALL_DIR) $(1)/usr/libexec/netifyd
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/deploy/functions.sh $(1)/usr/libexec/netifyd
endef

# Get the job done
$(eval $(call BuildPackage,netifyd))
