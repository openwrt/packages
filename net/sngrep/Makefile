#
# Copyright (C) 2016 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sngrep
PKG_VERSION:=20160923-devel
PKG_RELEASE:=1
PKG_MAINTAINER:=Daniel Engberg <daniel.engberg.lists@pyret.net>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/irontec/sngrep
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=1e0ee528d0f400d42ce482518c805a86f9b61cef
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/sngrep
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpcap +libpthread +libpcre +libncursesw
  TITLE:=Display SIP calls message flows
  URL:=https://github.com/irontec/sngrep
endef

define Package/sngrep/description
  sngrep is a tool for displaying SIP calls message flows from terminal.
  It supports live capture to display realtime SIP packets and can also be used as PCAP viewer.
endef

CONFIGURE_ARGS += \
	--with-pcre \
	--enable-unicode \

define Package/sngrep/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/sngrep $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,sngrep))
