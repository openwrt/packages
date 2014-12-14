#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=procps
PKG_VERSION:=3.2.8
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING COPYING.LIB

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://procps.sourceforge.net
PKG_MD5SUM:=9532714b6846013ca9898984ba4cd7e0

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

PROCPS_APPLETS := \
    ps free pgrep pkill pmap pwdx skill w \
    slabtop snice tload top vmstat watch

define Package/procps/Default
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libncurses
  TITLE:=proc utilities
  URL:=http://procps.sourceforge.net/
  MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
endef

define Package/procps
  $(call Package/procps/Default)
  MENU:=1
endef

define Package/procps/description
 procps is the package that has a bunch of small useful utilities that give
 information about processes using the /proc filesystem. The package
 includes the programs ps, top, vmstat, w, kill, free, slabtop, and skill.
endef

define GenPlugin
 define Package/$(1)
   $(call Package/procps/Default)
   DEPENDS:=procps
   TITLE:=Applet $(2) from the procps package
   DEFAULT:=y
 endef

 define Package/$(1)/description
  Installs the applet $(2).
 endef
endef

$(foreach a,$(PROCPS_APPLETS),$(eval $(call GenPlugin,procps-$(a),$(a))))

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \

define Package/procps/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/proc/libproc-$(PKG_VERSION).so $(1)/usr/lib/
endef

AUXDIR_ps := "ps/"

define BuildPlugin
  define Package/$(1)/install
	$(INSTALL_DIR) $$(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(AUXDIR_$(2))$(2) $$(1)/usr/bin/
  endef

  $$(eval $$(call BuildPackage,$(1)))
endef

$(foreach a,$(PROCPS_APPLETS),$(eval $(call BuildPlugin,procps-$(a),$(a))))
$(eval $(call BuildPackage,procps))
