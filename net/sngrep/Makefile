#
# Copyright (C) 2016-2018 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sngrep
PKG_VERSION=1.4.5-rc1
PKG_RELEASE:=1
PKG_MAINTAINER:=
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_URL:=https://codeload.github.com/irontec/$(PKG_NAME)/tar.gz/5f97547?dummy=/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=1e03bb8506753483929223c46ca83908699df3cb2f577a9676b21130212da99c
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-5f97547

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
