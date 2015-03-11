#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libesmtp
PKG_VERSION:=1.0.6
PKG_RELEASE:=2
PKG_MD5SUM:=c4fedc999b6c3820296b0eb92cc2e252

PKG_MAINTAINER:=Othmar Truniger <github@truniger.ch>
PKG_LICENSE:=LGPL-2.0+
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_URL:=http://www.stafford.uklinux.net/libesmtp
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libesmtp
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A Library for Posting Electronic Mail
  URL:=http://www.stafford.uklinux.net/libesmtp/
  DEPENDS:=+libpthread
endef

CONFIGURE_ARGS += \
	--without-openssl

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/libesmtp-config $(1)/usr/bin/
	$(SED) 's,^\(prefix\|exec_prefix\)=.*,\1=$(STAGING_DIR)/usr,g' $(1)/usr/bin/libesmtp-config

	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libesmtp.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(2)/bin
	$(LN) ../../usr/bin/libesmtp-config $(2)/bin/
endef

define Package/libesmtp/install
	$(INSTALL_DIR)  $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libesmtp.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libesmtp))
