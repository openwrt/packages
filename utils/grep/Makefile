#
# Copyright (C) 2010-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=grep
PKG_VERSION:=3.7
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNU/grep
PKG_HASH:=5c10da312460aec721984d5d83246d24520ec438dd48d7ab5a05dbc0d6d6823c

PKG_MAINTAINER:=Julen Landa Alustiza <julen@zokormazo.info>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:gnu:grep

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

MAKE_FLAGS += SHELL="/bin/sh"

include $(INCLUDE_DIR)/package.mk

define Package/grep
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=grep search utility - full version
  DEPENDS:=+libpcre
  URL:=https://www.gnu.org/software/grep/
  ALTERNATIVES:=\
    300:/bin/egrep:/usr/libexec/egrep-gnu \
    300:/bin/fgrep:/usr/libexec/fgrep-gnu \
    300:/bin/grep:/usr/libexec/grep-gnu
endef

define Package/grep/description
The grep command searches one or more input files for lines
containing a match to a specified pattern. By default, grep
prints the matching lines.
endef

define Package/grep/install
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/egrep $(1)/usr/libexec/egrep-gnu
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/fgrep $(1)/usr/libexec/fgrep-gnu
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/grep $(1)/usr/libexec/grep-gnu
endef

$(eval $(call BuildPackage,grep))
