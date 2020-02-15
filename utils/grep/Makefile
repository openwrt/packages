#
# Copyright (C) 2010-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=grep
PKG_VERSION:=3.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNU/grep
PKG_HASH:=58e6751c41a7c25bfc6e9363a41786cff3ba5709cf11d5ad903cf7cce31cc3fb

PKG_MAINTAINER:=Julen Landa Alustiza <julen@zokormazo.info>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:gnu:grep

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/grep
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=grep search utility - full version
  DEPENDS:=+libpcre
  URL:=https://www.gnu.org/software/grep/
endef

define Package/grep/description
The grep command searches one or more input files for lines
containing a match to a specified pattern. By default, grep
prints the matching lines.
endef

define Package/grep/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin
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
