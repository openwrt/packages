#
# Author: Tibor Dudlák
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tang
PKG_VERSION:=12
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/latchset/$(PKG_NAME)/releases/download/v$(PKG_VERSION)/
PKG_HASH:=892e0b26ee2db01f2c257b083fbb85aede7d3f59de7361c9c9528c0d5783e69c

PKG_MAINTAINER:=Tibor Dudlák <tibor.dudlak@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/tang
  SECTION:=utils
  TITLE:=tang v$(PKG_VERSION) - daemon for binding data to the presence of a third party
  DEPENDS:=+libhttp-parser +jose +bash
  URL:=https://github.com/latchset/tang
endef

define Package/tang/description
	Tang is a small daemon for binding data to the presence of a third party.
endef

define Package/tang/conffiles
/usr/share/tang/db/
endef

define Package/tang/install
	$(INSTALL_DIR)	$(1)/usr/bin
	$(INSTALL_DIR)	$(1)/usr/sbin
	$(INSTALL_BIN)	$(PKG_INSTALL_DIR)/usr/bin/tang-show-keys	$(1)/usr/bin/
	$(INSTALL_BIN)  $(PKG_INSTALL_DIR)/usr/libexec/tangd*		$(1)/usr/sbin/
	$(INSTALL_DIR)  $(1)/etc/init.d
	$(INSTALL_BIN)  ./files/tang.init $(1)/etc/init.d/tang
	$(INSTALL_DIR)  $(1)/etc/config
	$(INSTALL_CONF) ./files/config $(1)/etc/config/tang
endef

$(eval $(call BuildPackage,tang))
