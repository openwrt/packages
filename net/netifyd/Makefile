# Netify Agent
# Copyright (C) 2016-2018 eGloo, Incorporated
#
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

# Name, version and release number
# The name and version of your package are used to define the variable to point to the build directory of your package: $(PKG_BUILD_DIR)
PKG_NAME:=netifyd
PKG_VERSION:=2.64
PKG_RELEASE:=1

PKG_INSTALL:=1
#PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_MAINTAINER:=Darryl Sokoloski <darryl@egloo.ca>
PKG_LICENSE:=GPL-3.0+

# Source settings

# Disable the following and enable SOURCE_DIR below for local test builds.
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://bitbucket.org/eglooca/netify-daemon.git
PKG_SOURCE_DATE:=2018-06-05
PKG_SOURCE_VERSION:=4aa933a603a338be4cd7d0634def2cbeb78c85c1
PKG_MIRROR_HASH:=849e8c7eb7c6e7f774172abf535fa3fc9315679cab03b5bcb7288ad60ea58593

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

CONFIGURE_ARGS += \
	--disable-inotify \
	--disable-ncurses \
	--without-systemdsystemunitdir

# Package preparation
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -a $(SOURCE_DIR)/. $(PKG_BUILD_DIR)/
	$(Build/Patch)
endef

# Package install
define Package/netifyd/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/netifyd.init $(1)/etc/init.d/netifyd
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/netifyd $(1)/usr/sbin
	#$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/var/lib/netifyd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/deploy/app-custom-match.conf $(1)/var/lib/netifyd
endef

# Get the job done
$(eval $(call BuildPackage,netifyd))
