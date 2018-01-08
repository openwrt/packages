#
# Copyright (C) 2016-2018 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sipgrep
PKG_VERSION:=snapshot-20161008
PKG_RELEASE:=1
PKG_MAINTAINER:=
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_URL:=https://codeload.github.com/sipcapture/$(PKG_NAME)/tar.gz/c974e75?dummy=/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=94114f79ed638ad7ea7f2a2ca2df740b6bbd7ea5ee1ffb7cd465427cda0f3d90
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-c974e75

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
