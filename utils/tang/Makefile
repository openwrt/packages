#
# Author: Tibor Dudlák
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tang
PKG_VERSION:=15
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/latchset/$(PKG_NAME)/releases/download/v$(PKG_VERSION)/
PKG_HASH:=eaf4a2abfea3d05f454a8841e98332be1e1e2432744c70bb7765651ed82c3f7c

PKG_MAINTAINER:=Nikos Mavrogiannopoulos <n.mavrogiannopoulos@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:tang_project:tang

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/tang
  SECTION:=utils
  TITLE:=tang v$(PKG_VERSION) - daemon for binding data to the presence of a third party
  DEPENDS:=+libhttp-parser +jose
  URL:=https://github.com/latchset/tang
  USERID:=tang:tang
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
