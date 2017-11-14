#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shadow
PKG_VERSION:=4.2.1
PKG_RELEASE:=8

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://pkg-shadow.alioth.debian.org/releases
PKG_HASH:=3b0893d1476766868cd88920f4f1231c4795652aa407569faff802bcda0f3d41
PKG_MAINTAINER:=Steven Barth <cyrus@openwrt.org>
PKG_LICENSE:=BSD-3-Clause

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

SHADOW_APPLETS := \
	chage chpasswd chfn chsh expiry faillog gpasswd \
	groupadd groupdel groupmems groupmod groups \
	lastlog login newgidmap newgrp newuidmap nologin \
	passwd su \
	useradd userdel usermod vipw

CONFIGURE_ARGS += \
	--without-audit \
	--without-libpam \
	--without-selinux \
	--without-acl \
	--without-attr \
	--without-tcb \
	--without-nscd

define Package/shadow/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=The PLD Linux shadow utilities
  URL:=http://pkg-shadow.alioth.debian.org/
endef

define Package/shadow
  $(call Package/shadow/Default)
  TITLE+= (all)
  DEPENDS:=$(foreach u,$(SHADOW_APPLETS),+shadow-$(u))
  HIDDEN:=1
endef

define Package/shadow/description
  Full versions of standard shadow utilities. Normally, you would not
  use this package, since the functionality in BusyBox is more than
  sufficient and much smaller.
endef

define Package/shadow/install
	true
endef

define Package/shadow-utils
  $(call Package/shadow/Default)
endef

define Package/shadow-utils/config
    menu "Select shadow utilities"
      depends on PACKAGE_shadow-utils

    config shadow-all
      bool "Include all PLD shadow utilities"
      select PACKAGE_shadow
      default y

    comment "Utilities"

  $(foreach u,$(SHADOW_APPLETS), \
    config PACKAGE_shadow-$(u)
      prompt "Full PLD version of $(u) utility"

   )

  endmenu

endef

Package/shadow-utils/description = $(Package/shadow/description)

define Package/shadow-common
  $(call Package/shadow/Default)
  TITLE:=Shared definitions for the PLD Linux shadow utilities
  DEPENDS:=$(ICONV_DEPENDS) $(INTL_DEPENDS)
  HIDDEN:=1
endef

define GenPlugin
  define Package/shadow-$(1)
    $(call Package/shadow/Default)
    TITLE:=Utility $(1) from the PLD Linux shadow utilities
    DEPENDS:=+shadow-common
    HIDDEN:=1
  endef

  define Package/shadow-$(1)/description
    Full version of standard $(1) utility. Normally, you would not use this
    package, since the functionality in BusyBox is more than sufficient.
  endef
endef

$(foreach u,$(SHADOW_APPLETS),$(eval $(call GenPlugin,$(u))))

define Package/shadow-common/conffiles
/etc/login.defs
endef

define Package/shadow-common/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/login.defs $(1)/etc/
endef

define Package/shadow-utils/install
	true
endef

define BuildPlugin
  define Package/shadow-$(1)/install
	[ -x "$(PKG_INSTALL_DIR)/usr/sbin/$(1)" ] && { \
		$(INSTALL_DIR) $$(1)/usr/sbin; \
		$(CP) $(PKG_INSTALL_DIR)/usr/sbin/$(1) $$(1)/usr/sbin/; \
	} || { \
		$(INSTALL_DIR) $$(1)/usr/bin; \
		$(CP) $(PKG_INSTALL_DIR)/usr/bin/$(1) $$(1)/usr/bin/; \
	}
  endef

  $$(eval $$(call BuildPackage,shadow-$(1)))
endef

$(foreach u,$(SHADOW_APPLETS),$(eval $(call BuildPlugin,$(u))))

$(eval $(call BuildPackage,shadow-utils))
$(eval $(call BuildPackage,shadow-common))
$(eval $(call BuildPackage,shadow))
