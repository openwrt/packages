#
# Copyright (C) 2007-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=iperf
PKG_VERSION:=2.1.9
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=5c0771aab00ef14520013aef01675977816e23bb8f5d9fde016f90eb2f1be788
PKG_SOURCE_URL:=@SF/iperf2

PKG_MAINTAINER:=Felix Fietkau <nbd@nbd.name>
PKG_LICENSE:=BSD-3-Clause
PKG_CPE_ID:=cpe:/a:iperf_project:iperf

PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=lto

PKG_CONFIG_DEPENDS:=CONFIG_IPERF_ENABLE_MULTICAST

include $(INCLUDE_DIR)/package.mk

define Package/iperf
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:= +libstdcpp +libpthread
  TITLE:=Internet Protocol bandwidth measuring tool
  URL:=http://sourceforge.net/projects/iperf2/
endef

define Package/iperf/description
 Iperf is a modern alternative for measuring TCP and UDP bandwidth
 performance, allowing the tuning of various parameters and
 characteristics.
endef

define Package/iperf/config
	config IPERF_ENABLE_MULTICAST
		depends on PACKAGE_iperf
		bool "Enable multicast support"
endef

CONFIGURE_ARGS += \
	--enable-fastsampling \
	$(call autoconf_bool,CONFIG_IPERF_ENABLE_MULTICAST,multicast) \
	$(call autoconf_bool,CONFIG_IPV6,ipv6)

TARGET_CXXFLAGS += -fno-rtti -static-libstdc++ -std=c++11
TARGET_LDFLAGS += $(if $(CONFIG_USE_GLIBC),-lpthread -lm)

define Package/iperf/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/iperf $(1)/usr/bin/iperf
endef

$(eval $(call BuildPackage,iperf))
