#
# Copyright (C) 2017 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=clamsmtp
PKG_VERSION:=1.10
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://thewalter.net/stef/software/clamsmtp/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MD5SUM:=b068ba6e444859782bbdd88f290c1abf

MAINTAINER:=Lucian Cristian <lucian.cristian@gmail.com>
PKG_LICENSE:=GPLv2

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=mail
  CATEGORY:=Mail
  DEPENDS:=+libpthread +clamav
  TITLE:=$(PKG_NAME)
  URL:=http://thewalter.net/stef/software/clamsmtp/
  PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
	ClamSMTP is an SMTP filter that allows you to check for viruses using the ClamAV anti-virus software.
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR)  $(1)/usr/sbin \
			$(1)/etc/init.d
	$(CP) $(PKG_BUILD_DIR)/src/clamsmtpd $(1)/usr/sbin/
	$(CP) $(PKG_BUILD_DIR)/doc/clamsmtpd.conf $(1)/etc/
	$(INSTALL_BIN) ./files/clamsmtpd.init $(1)/etc/init.d/clamsmtpd
endef

$(eval $(call BuildPackage,$(PKG_NAME)))