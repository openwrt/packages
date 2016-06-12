#
# Copyright (C) 2010-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=less
PKG_VERSION:=481
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.greenwoodsoftware.com/less
PKG_MD5SUM:=50ef46065c65257141a7340123527767

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Julen Landa Alustiza <julen@zokormazo.info>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/less/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Pager program similar to more
  URL:=http://www.greenwoodsoftware.com/less/
endef

define Package/less/Default/description
  Full version of GNU less utility
endef

define Package/less
  $(call Package/less/Default)
  DEPENDS:=+less-bin
endef

define Package/less/description
  $(call Package/less/Default/description)
  This is a metapackage that depends on either full version of less.
endef


define Package/less-narrow
  $(call Package/less/Default)
  DEPENDS:=+libncurses
  VARIANT:=narrow
  PROVIDES:=less-bin
endef

define Package/less-narrow/description
  $(call Package/less/Default/description)
  This installs the non-Unicode version of less.
endef

define Package/less-wide
  $(call Package/less/Default)
  TITLE+= (Unicode)
  DEPENDS:=+libncursesw
  VARIANT:=wide
  PROVIDES:=less-bin
endef

define Package/less-wide/description
  $(call Package/less/Default/description)
  This package contains the Unicode enabled version of less.
endef

ifeq ($(BUILD_VARIANT),narrow)
	CONFIGURE_VARS += \
		ac_cv_lib_ncursesw_initscr=no		
endif

ifeq ($(BUILD_VARIANT),wide)
	CONFIGURE_VARS += \
		ac_cv_lib_ncursesw_initscr=yes
endif

define Package/less/install
	true
endef

define Package/less-narrow/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/less $(1)/usr/bin/
endef

Package/less-wide/install = $(Package/less-narrow/install)

$(eval $(call BuildPackage,less))
$(eval $(call BuildPackage,less-narrow))
$(eval $(call BuildPackage,less-wide))
