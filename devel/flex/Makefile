# SPDX-Identifier-License: GPL-2.0-only
#
# Copyright (C) 2022 W. Michael Petullo <mike@flyn.org>

include $(TOPDIR)/rules.mk

PKG_NAME:=flex
PKG_VERSION:=2.6.4
PKG_RELEASE:=$(AUTORELEASE)
PKG_CPE_ID:=cpe:/a:flex_project:flex

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/westes/flex/releases/download/v$(PKG_VERSION)/
PKG_HASH:=e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995

PKG_FIXUP:=autoreconf

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/flex
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=flex
  URL:=https://github.com/westes/flex
endef

define Package/flex/description
  flex is a tool for generating scanners: programs which recognize lexical patterns in text
endef

CONFIGURE_ARGS += --disable-shared --disable-bootstrap

define Package/flex/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/bin/flex \
		$(1)/usr/bin/
endef

$(eval $(call BuildPackage,flex))
