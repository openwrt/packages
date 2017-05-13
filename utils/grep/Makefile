#
# Copyright (C) 2010-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=grep
PKG_VERSION:=2.26
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNU/grep
PKG_MD5SUM:=afdd61c7221434722671baf002ac9267

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Julen Landa Alustiza <julen@zokormazo.info>

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS+=--std=gnu99

define Package/grep
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=grep search utility - full version
  DEPENDS:=+libpcre
  URL:=http://www.gnu.org/software/grep/
endef

define Package/grep/description
The grep command searches one or more input files for lines
containing a match to a specified pattern. By default, grep
prints the matching lines.
endef

define Package/grep/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/grep $(1)/usr/bin/grep
endef

define Package/grep/postinst
#!/bin/sh
[ -L "$${IPKG_INSTROOT}/bin/grep" ] && rm -f "$${IPKG_INSTROOT}/bin/grep"
exit 0
endef

define Package/grep/prerm
$${IPKG_INSTROOT}/bin/busybox grep -h 2>&1 | grep -q BusyBox && \
ln -sf busybox $${IPKG_INSTROOT}/bin/grep
exit 0
endef

$(eval $(call BuildPackage,grep))
