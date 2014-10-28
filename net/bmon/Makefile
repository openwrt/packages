#
# Copyright (C) 2007 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bmon
PKG_VERSION:=2.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://people.suug.ch/~tgr/bmon/files/
PKG_MD5SUM:=3111a027907016c0902d67350c619df6

include $(INCLUDE_DIR)/package.mk

define Package/bmon
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libncurses
  TITLE:=bmon is a portable bandwidth monitor
  URL:=http://people.suug.ch/~tgr/bmon/
endef

define Package/bmon/description
	bmon is a portable bandwidth monitor
	and rate estimator running on various
	operating systems. It supports various
	input methods for different architectures.
endef

CONFIGURE_ARGS += \
	--disable-cnt-workaround \
	--disable-dbi \
	--disable-rrd \
	--disable-asound \

CONFIGURE_VARS += \
	ac_cv_lib_nl_nl_connect=no \

define Package/bmon/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/bmon $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,bmon))
