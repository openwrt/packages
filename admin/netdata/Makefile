#
# Copyright (C) 2008-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=netdata
PKG_VERSION:=1.16.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>, Daniel Engberg <daniel.engberg.lists@pyret.net>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:my-netdata:netdata

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/netdata/netdata/releases/download/v$(PKG_VERSION)
PKG_HASH:=d62ae89c7b9e93d40feca6edd26b77c6e27e17caa2f90a50a1a7a677f6cc8b4f
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-v$(PKG_VERSION)

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk

define Package/netdata
  SECTION:=admin
  CATEGORY:=Administration
  DEPENDS:=+zlib +libuuid +libmnl +libopenssl +liblz4
  TITLE:=Real-time performance monitoring tool
  URL:=https://www.netdata.cloud/
endef

define Package/netdata/description
  netdata is a highly optimized Linux daemon providing real-time performance
  monitoring for Linux systems, applications and SNMP devices over the web.

  If you want to use Python plugins install python3, python3-yaml and
  python3-urllib3
endef

TARGET_CFLAGS := $(filter-out -O%,$(TARGET_CFLAGS))
TARGET_CFLAGS += -ffunction-sections -fdata-sections -O3
TARGET_LDFLAGS += -Wl,--gc-sections

CONFIGURE_ARGS += \
	--with-zlib \
	--with-math \
	--disable-x86-sse \
	--enable-lto \
	--without-libcap \
	--disable-plugin-nfacct

define Package/netdata/conffiles
/etc/netdata/
endef

define Package/netdata/install
	$(INSTALL_DIR) $(1)/etc/netdata/custom-plugins.d
	$(CP) $(PKG_INSTALL_DIR)/etc/netdata $(1)/etc
	$(CP) ./files/netdata.conf $(1)/etc/netdata
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/netdata $(1)/usr/lib
	$(CP) $(1)/usr/lib/netdata/conf.d/fping.conf $(1)/etc
	$(CP) $(1)/usr/lib/netdata/conf.d/health_alarm_notify.conf $(1)/etc
	rm -rf $(1)/usr/lib/netdata/python.d/python_modules/pyyaml2
	rm -rf $(1)/usr/lib/netdata/python.d/python_modules/pyyaml3
	rm -rf $(1)/usr/lib/netdata/python.d/python_modules/urllib3
	$(CP) $(1)/usr/lib/netdata/plugins.d/tc-qos-helper.sh $(1)/etc
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/netdata $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/share/netdata
	$(CP) $(PKG_INSTALL_DIR)/usr/share/netdata $(1)/usr/share
	rm $(1)/usr/share/netdata/web/demo*html
	rm $(1)/usr/share/netdata/web/fonts/*.svg
	rm $(1)/usr/share/netdata/web/fonts/*.ttf
	rm $(1)/usr/share/netdata/web/fonts/*.woff
	rm $(1)/usr/share/netdata/web/images/*.png
	rm $(1)/usr/share/netdata/web/images/*.gif
	rm $(1)/usr/share/netdata/web/images/*.ico
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/netdata.init $(1)/etc/init.d/netdata
endef

$(eval $(call BuildPackage,netdata))
