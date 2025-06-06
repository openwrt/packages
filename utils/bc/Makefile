#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bc
PKG_VERSION:=1.07.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/bc
PKG_HASH:=62adfca89b0a1c0164c2cdca59ca210c1d44c3ffc46daf9931cf4942664cb02a

PKG_MAINTAINER:=Aleksey Vasilenko <aleksey.vasilenko@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_FIXUP:=autoreconf
PKG_CPE_ID:=cpe:/a:gnu:bc

TARGET_CFLAGS += $(FPIC) -std=gnu17

include $(INCLUDE_DIR)/package.mk

define Package/bc/Default
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=https://www.gnu.org/software/bc/
endef

define Package/bc
  $(call Package/bc/Default)
  TITLE:=Arbitrary precision calculator language
  DEPENDS:=+libreadline +libncurses
endef

define Package/bc/description
 bc is a language that supports arbitrary precision numbers with
 interactive execution of statements.
endef

define Package/dc
  $(call Package/bc/Default)
  TITLE:=Arbitrary precision reverse-polish calculator
  DEPENDS:=bc
endef

define Package/dc/description
 dc is a reverse-polish desk calculator which supports unlimited
 precision arithmetic.
endef

CONFIGURE_ARGS += --with-readline

define Package/bc/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bc/bc $(1)/usr/bin/
endef

define Package/dc/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dc/dc $(1)/usr/bin/
endef

$(eval $(call BuildPackage,bc))
$(eval $(call BuildPackage,dc))
