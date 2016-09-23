#
# Copyright (C) 2016 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sipgrep
PKG_VERSION:=20160914-devel
PKG_RELEASE:=1
PKG_MAINTAINER:=Daniel Engberg <daniel.engberg.lists@pyret.net>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/sipcapture/sipgrep
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=df8a95b066569be92aa38cad01086ea595b36863
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/sipgrep
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpcap +libpcre +libncursesw
  TITLE:=Display and Troubleshoot SIP signaling in CLI
  URL:=https://github.com/sipcapture/sipgrep
endef

define Package/sipgrep/description
  SipGrep is a utility for displaying and troubleshooting SIP signaling.
endef

CONFIGURE_ARGS += \
	--enable-ncurses

define Package/sipgrep/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/sipgrep $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,sipgrep))
