#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cgminer
PKG_VERSION:=20160207
PKG_REV:=43bf1d3

PKG_RELEASE:=1
PKG_INSTALL:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_REV).tar.bz2
PKG_SOURCE_URL:=git://github.com/ckolivas/cgminer.git
PKG_SOURCE_PROTO:=git
PKG_MD5SUM:=69589554a413839de908c8b0b81f0e7b
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Mike Qin <Fengling.Qin@gmail.com>

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/cgminer
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=CGMiner
	URL:=https://github.com/ckolivas/cgminer
	DEPENDS:=+libcurl +libpthread +jansson +udev
endef

define Package/cgminer/description
Cgminer is a multi-threaded multi-pool GPU, FPGA and CPU miner with ATI GPU
monitoring, (over)clocking and fanspeed support for bitcoin and derivative
coins. Do not use on multiple block chains at the same time!
endef

define Package/cgminer/config
	menu "Configuration"
	depends on PACKAGE_cgminer
	source "$(SOURCE)/Config.in"
	endmenu
endef

TARGET_LDFLAGS += -Wl,-rpath-link=$(STAGING_DIR)/usr/lib

CONFIGURE_ARGS += --without-curses

ifeq ($(CONFIG_CGMINER_AVALON6),y)
	CONFIGURE_ARGS += --enable-avalon4
endif

ifeq ($(CONFIG_CGMINER_AVALON_MINER),y)
	CONFIGURE_ARGS += --enable-avalon-miner
endif

ifeq ($(CONFIG_CGMINER_ICARUS),y)
	CONFIGURE_ARGS += --enable-icarus
endif

ifeq ($(CONFIG_CGMINER_BFL),y)
	CONFIGURE_ARGS += --enable-bflsc
endif

define Build/Compile
	$(call Build/Compile/Default)
	(cd $(PKG_BUILD_DIR) && \
	 $(TARGET_CC) -Icompat/jansson-2.6/src -Icompat/libusb-1.0/libusb api-example.c -o cgminer-api;)
endef

define Package/cgminer/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cgminer-api	   $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/cgminer  $(1)/usr/bin

ifeq ($(CONFIG_CGMINER_AVALON6),y)
	$(INSTALL_BIN) $(FILES_DIR)/cgminer.avalon6.init           $(1)/etc/init.d/cgminer
	$(CP)          $(FILES_DIR)/cgminer.avalon6.config         $(1)/etc/config/cgminer
endif

ifeq ($(CONFIG_CGMINER_AVALON_MINER),y)
	$(INSTALL_BIN) $(FILES_DIR)/cgminer.avalon_miner.init           $(1)/etc/init.d/cgminer
	$(CP)          $(FILES_DIR)/cgminer.avalon_miner.config         $(1)/etc/config/cgminer
endif

ifeq ($(CONFIG_CGMINER_ICARUS),y)
	$(INSTALL_BIN) $(FILES_DIR)/cgminer.common.init           $(1)/etc/init.d/cgminer
	$(CP)          $(FILES_DIR)/cgminer.common.config         $(1)/etc/config/cgminer
endif

ifeq ($(CONFIG_CGMINER_BFL),y)
	$(INSTALL_BIN) $(FILES_DIR)/cgminer.common.init           $(1)/etc/init.d/cgminer
	$(CP)          $(FILES_DIR)/cgminer.common.config         $(1)/etc/config/cgminer
endif
endef

$(eval $(call BuildPackage,cgminer))
