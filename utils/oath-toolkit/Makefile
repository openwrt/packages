#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=oath-toolkit
PKG_VERSION:=2.6.5
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SAVANNAH/oath-toolkit
PKG_HASH:=d207120c7e7fdd540142d04ca06d83fb3277c8f2fb794a74535d04b2aa0ec219

PKG_MAINTAINER:=Fam Zheng <fam@euphon.net>
PKG_LICENSE:=LGPL-2.0-or-later GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:nongnu:oath_toolkit

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-xmltest \
	--disable-pskc

define Package/liboath
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A shared and static C library for OATH handling
  URL:=http://www.nongnu.org/oath-toolkit/index.html
endef

define Package/oath-pam
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=The oath PAM module
  URL:=http://www.nongnu.org/oath-toolkit/index.html
  DEPENDS:= +libpam +liboath
endef

define Package/oath-toolkit
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=A command line tool for generating and validating OTPs
  URL:=http://www.nongnu.org/oath-toolkit/index.html
  DEPENDS:= +liboath
endef

define Package/liboath/description
  The OATH Toolkit provide components for building one-time password
  authentication systems. It contains shared libraries, command line
  tools and a PAM module. Supported technologies include the event-based
  HOTP algorithm (RFC4226) and the time-based TOTP algorithm (RFC6238).
endef

Package/oath-pam/description = $(Package/liboath/description)

Package/oath-toolkit/description = $(Package/liboath/description)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/liboath
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
endef

define Package/liboath/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liboath.so* $(1)/usr/lib/
endef

define Package/oath-pam/install
	$(INSTALL_DIR) $(1)/usr/lib/security
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/security/pam_oath.so* $(1)/usr/lib/security/
endef

define Package/oath-toolkit/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/oathtool $(1)/usr/bin/
endef

$(eval $(call BuildPackage,liboath))
$(eval $(call BuildPackage,oath-pam))
$(eval $(call BuildPackage,oath-toolkit))
