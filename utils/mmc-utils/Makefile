#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mmc-utils
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://git.kernel.org/pub/scm/utils/mmc/mmc-utils.git
PKG_SOURCE_DATE:=2021-10-01
PKG_SOURCE_VERSION:=7769a4d7abe339ce273c13a203394a79a11fcff9
PKG_MIRROR_HASH:=4feb754875b680dfd815e1776e308d3296be84e4a345d9062677d5e7ee5490ed

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=

PKG_MAINTAINER:=Michael Heimpold <mhei@heimpold.de>

include $(INCLUDE_DIR)/package.mk

define Package/mmc-utils
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Userspace tools for MMC/SD devices
  URL:=http://git.kernel.org/cgit/linux/kernel/git/cjb/mmc-utils.git
endef

define Package/mmc-utils/description
  This package contains the userspace mmc utils, the userspace
  counterpart to the Linux MMC/SD subsystem.
endef

define Build/Configure
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
	        $(TARGET_CONFIGURE_OPTS) CFLAGS="$(TARGET_CFLAGS) -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2" \
	        mmc
endef

define Package/mmc-utils/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mmc $(1)/sbin
endef

$(eval $(call BuildPackage,mmc-utils))
