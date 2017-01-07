#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=logrotate
PKG_VERSION:=3.10.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:= https://github.com/logrotate/logrotate/releases/download/$(PKG_VERSION)
PKG_MD5SUM:=888f58caf07082c76f5dd39e5d30ec12
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/logrotate
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libpopt
  TITLE:=rotates, compresses, and mails system logs
  URL:=https://github.com/logrotate/logrotate
  MAINTAINER:=Christian Beier <cb@shoutrlabs.com>
endef

define Package/logrotate/description
 logrotate is designed to ease administration of systems that generate large
 numbers of log files. It allows auto-matic rotation, compression, removal and
 mailing of log files. Each log file may be handled daily, weekly, monthly or
 when it grows too large.
endef

define Package/logrotate/conffiles
/etc/logrotate.conf
endef

CONFIGURE_ARGS += --with-acl=no

EXTRA_CFLAGS += $(TARGET_CPPFLAGS) -Wno-nonnull-compare
EXTRA_LDFLAGS += $(TARGET_LDFLAGS)

define Build/Compile
	$(call Build/Compile/Default, \
		RPM_OPT_FLAGS:="$(TARGET_CFLAGS) $(EXTRA_CFLAGS)" \
		LDFLAGS="$(EXTRA_LDFLAGS)" \
		logrotate \
	)
endef

define Package/logrotate/install	
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ${PKG_BUILD_DIR}/logrotate $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) ./files/logrotate.conf $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/logrotate.d
endef

$(eval $(call BuildPackage,logrotate))
