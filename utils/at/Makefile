#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=at
PKG_VERSION:=3.1.20
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).orig.tar.gz
PKG_SOURCE_URL:=http://ftp.debian.org/debian/pool/main/a/at
PKG_HASH:=0871923cab73050b98ace020664eb2ddc1e669e4166b5abb64d864d02fcefab9

PKG_LICENSE:=GPL-2.0+ GPL-3.0+ ISC
PKG_LICENSE_FILES:=COPYING Copyright
PKG_MAINTAINER:=Phil Eichinger <phil@zankapfel.net>

include $(INCLUDE_DIR)/package.mk

define Package/at
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libelf1
  TITLE:=Delayed job execution and batch processing
  URL:=http://packages.debian.org/stable/at
endef

define Package/at/description
 At and batch read shell commands from standard input storing them as a job to
 be scheduled for execution in the future.
endef

export SENDMAIL=/bin/true
EXTRA_CFLAGS:=-DNEED_YYWRAP -I$(PKG_BUILD_DIR) \
	$(TARGET_LDFLAGS)

CONFIGURE_ARGS+=--prefix=/usr \
		--with-daemon_username=nobody \
		--with-daemon_groupname=nogroup \
		--with-jobdir=/var/spool/cron/atjobs \
		--with-atspool=/var/spool/cron/atspool

CONFIGURE_VARS += \
	ac_cv_header_security_pam_appl_h=no

define Package/at/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/sbin $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/atd.init $(1)/etc/init.d/atd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/at $(1)/usr/bin
	ln -sf at $(1)/usr/bin/atq
	ln -sf at $(1)/usr/bin/atrm
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/atd $(1)/usr/sbin
endef

$(eval $(call BuildPackage,at))
