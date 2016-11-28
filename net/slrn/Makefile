#
# Copyright (C) 2016 Nikil Mehta <nikil.mehta@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=slrn
PKG_MAJOR_VERSION:=1.0.3
PKG_MINOR_VERSION:=a
PKG_VERSION:=$(PKG_MAJOR_VERSION)$(PKG_MINOR_VERSION)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://jedsoft.org/releases/slrn/
PKG_MD5SUM:=3ba8a4d549201640f2b82d53fb1bec1250f908052a7983f0061c983c634c2dac

PKG_MAINTAINER:=Nikil Mehta <nikil.mehta@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_MAJOR_VERSION)
PKG_INSTALL:=1 

include $(INCLUDE_DIR)/package.mk

define Package/slrn
  SECTION:=net
  CATEGORY:=Network
  TITLE:=threaded text-mode news reader
  URL:=http://slrn.sourceforge.net/
  DEPENDS:=+libopenssl +libslang2 +libuu
endef

define Package/slrn/description
	Slrn is a threaded news reader with color support that is designed to
	read news fast over slow links.
	.
	Slrn can read usenet news via NNTP or directly from a local news spool.
	.
	Slrn can be heavily customized from its rc file, and even includes a
	built in macro language. There is also support for killfiles and
	article scoring.
endef

CONFIGURE_VARS += \
	slrn_cv_va_copy=yes \
	slrn_cv___va_copy=yes \
	slrn_cv_va_val_copy=yes

CONFIGURE_ARGS += \
	--with-slang=$(STAGING_DIR)/usr \
	--with-uu=$(STAGING_DIR)/usr \
	--with-ssl \
	--with-slrnpull

define Package/slrn/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/{slrn,slrnpull} $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/share
	$(CP) $(PKG_INSTALL_DIR)/usr/share/slrn $(1)/usr/share/
endef

$(eval $(call BuildPackage,slrn))
