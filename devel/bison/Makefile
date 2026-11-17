# SPDX-Identifier-License: GPL-2.0-only
#
# Copyright (C) 2022 W. Michael Petullo <mike@flyn.org>

include $(TOPDIR)/rules.mk

PKG_NAME:=bison
PKG_VERSION:=3.8.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNU/$(PKG_NAME)
PKG_HASH:=9bba0214ccf7f1079c5d59210045227bcf619519840ebfa80cd3849cff5a5bf2

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:gnu:bison

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/bison
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=bison
  URL:=https://www.gnu.org/software/bison/
endef

define Package/bison/description
  Bison is a general-purpose parser generator
endef

CONFIGURE_ARGS += --enable-threads=posix --disable-nls

define Package/bison/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/bin/bison \
		$(1)/usr/bin/
endef

$(eval $(call BuildPackage,bison))
