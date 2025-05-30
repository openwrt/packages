#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bogofilter
PKG_VERSION:=1.3.0_rc1
# Drop and replace all uses below with PKG_VERSION upon final 1.3.0 release:
PKG_VERSION2:=1.3.0.rc1
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:bogofilter:bogofilter

PKG_SOURCE:=$(PKG_NAME)-$(PKG_NAME)-$(PKG_VERSION2).tar.bz2
PKG_SOURCE_URL:=https://gitlab.com/bogofilter/bogofilter/-/archive/$(PKG_NAME)-$(PKG_VERSION2)
PKG_HASH:=8d01dccaa7cac73ae88cc9d00ec28e5885589bd4413306c5671e9088d81bc9c8
# Source tarball named as indicated (double PKG_NAME), and directory therein
# follows the same name. Set PKG_BUILD_DIR here and MAKE_PATH,
# PKG_AUTOMAKE_PATHS, and PKG_BUILD_DIR below.
MAKE_PATH:=bogofilter
PKG_AUTOMAKE_PATHS:=$(MAKE_PATH)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_NAME)-$(PKG_VERSION2)

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/bogofilter
  SECTION:=mail
  CATEGORY:=Mail
  DEPENDS:=+libsqlite3
  TITLE:=bogofilter
  MAINTAINER:=W. Michael Petullo <mike@flyn.org>
  URL:=http://bogofilter.sourceforge.net/
endef

define Package/bogofilter/description
	Bogofilter is a fast Bayesian spam filter
endef

CONFIGURE_PATH:=bogofilter
MAKE_PATH:=bogofilter
PKG_AUTOMAKE_PATHS:=$(MAKE_PATH)

CONFIGURE_ARGS += \
	--with-database=sqlite3 \
	--with-included-gsl

define Package/bogofilter/conffiles
/etc/bogofilter.cf
endef

define Package/bogofilter/install
	$(INSTALL_DIR)  $(1)/etc/ \
                        $(1)/usr/bin \
                        $(1)/usr/sbin
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/$(MAKE_PATH)/bogofilter.cf.example $(1)/etc/bogofilter.cf
	$(INSTALL_BIN) ./files/postfix-bogofilter $(1)/usr/sbin/postfix-bogofilter
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/bf_compact $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/bf_copy $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/bf_tar $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/bogofilter $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/bogolexer $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/bogotune $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/bogoutil $(1)/usr/bin/
endef

$(eval $(call BuildPackage,bogofilter))
