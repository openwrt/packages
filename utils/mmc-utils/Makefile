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
PKG_SOURCE_URL:=https://git.kernel.org/pub/scm/linux/kernel/git/cjb/mmc-utils.git
PKG_SOURCE_DATE:=2018-12-09
PKG_SOURCE_VERSION:=485b05ec40031a06077db9c84ae75a36ebd3db25
PKG_MIRROR_HASH:=043d706a5bb7c206ccfdc1a5e604bf03bd744f8dcfaeccba1a7ef845a18fbd26

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=

PKG_MAINTAINER:=Michael Heimpold <mhei@heimpold.de>

PKG_BUILD_PARALLEL:=1

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
