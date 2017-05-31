#
# https://github.com/cornet/ccze
# 
# Copyright (C) 2007-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ccze
PKG_VERSION:=0.2.1
PKG_SOURCE_URL:=https://github.com/cornet/ccze/archive/master.zip
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/ccze
  SUBMENU:=Editors
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libncurses +libpcre
  TITLE:=A robust log colorizer, plugin infrastructure
  URL:=https://github.com/cornet/ccze
  MAINTAINER:=Gergely Nagy <algernon@bonehunter.rulez.org>
endef

define Package/ccze/description
  This manual page documents briefly the ccze utility, which is a drop-in replacement for colorize, but written in C, to be faster and
  less resource-hungry. The goal was to be fully backwards compatible, yet superior with respect to speed and features.
endef

CONFIGURE_ARGS += --with-builtins="dpkg httpd oops php squid syslog ulogd"

define Build/Configure
  $(call Build/Configure/Default,)
endef


define Package/ccze/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(1)/usr/bin/
endef

$(eval $(call BuildPackage,ccze))
