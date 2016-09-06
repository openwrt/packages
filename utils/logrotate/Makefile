#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=logrotate
PKG_VERSION:=3.8.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).orig.tar.gz
PKG_SOURCE_URL:= \
	http://ftp.debian.org/debian/pool/main/l/logrotate \
	http://ftp.de.debian.org/debian/pool/main/l/logrotate \
	http://ftp.fr.debian.org/debian/pool/main/l/logrotate \
	http://ftp.us.debian.org/debian/pool/main/l/logrotate
PKG_MD5SUM:=bd2e20d8dc644291b08f9215397d28a5

include $(INCLUDE_DIR)/package.mk

define Package/logrotate
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libpopt
  TITLE:=rotates, compresses, and mails system logs
  URL:=http://packages.debian.org/unstable/admin/logrotate
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

EXTRA_CFLAGS += $(TARGET_CPPFLAGS)
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
