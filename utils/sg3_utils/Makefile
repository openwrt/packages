#
# Copyright (C) 2007-2018 OpenWrt.org
# Copyright (C) 2018 Rosy Song <rosysong@rosinson.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sg3_utils
PKG_VERSION:=1.44
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://sg.danny.cz/sg/p
PKG_HASH:=ca94ac106510742cd8ff5ead4a7e5c89d410653291401daf4632d2bef2a35b05
PKG_MAINTAINER:=Rosy Song <rosysong@rosinson.com>

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/sg3_utils
  SUBMENU:=Disc
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=SCSI utility
  URL:=http://sg.danny.cz/sg/sg3_utils.html
endef

define Package/sg3_utils/description
	The sg3_utils package contains utilities that send SCSI commands to
	devices. As well as devices on transports traditionally associated with
	SCSI (e.g. Fibre Channel (FCP), Serial Attached SCSI (SAS) and the SCSI
	Parallel Interface(SPI)) many other devices use SCSI command sets.ATAPI
	cd/dvd drives and SATA disks that connect via a translation layer or a
	bridge device are examples of devices that use SCSI command sets.
endef

define Package/sg3_utils/config
	config PACKAGE_SG3_UTILS_ENABLE_STATIC
		bool "Build sg3_utils with static libraries"
		depends on PACKAGE_sg3_utils
		default n
	config PACKAGE_SG3_UTILS_ENABLE_SHARED
		bool "Build sg3_utils with shared libraries"
		depends on PACKAGE_sg3_utils
		default y
endef

ifeq ($(CONFIG_PACKAGE_SG3_UTILS_ENABLE_STATIC),)
  CONFIGURE_ARGS += --disable-static
endif
ifeq ($(CONFIG_PACKAGE_SG3_UTILS_ENABLE_SHARED),)
  CONFIGURE_ARGS += --disable-shared
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
endef

define Package/sg3_utils/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,sg3_utils))
