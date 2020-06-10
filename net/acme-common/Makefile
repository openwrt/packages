#
# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=acme-common
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_MAINTAINER:= \
    Lucian Cristian <lucian.cristian@gmail.com> \
    Toke Høiland-Jørgensen <toke@toke.dk>
PKG_LICENSE:=GPL-3.0-or-later

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/acme-common
  SECTION:=net
  CATEGORY:=Network
  TITLE:=common files for acme and uacme client
endef

define Package/acme-common/Default/description
 Common files between acme and uacme app
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/acme-common/conffiles
/etc/config/acme
/etc/acme
endef

define Package/acme-common/install
	$(INSTALL_DIR) \
	 $(1)/etc/acme \
	 $(1)/etc/init.d \
	 $(1)/etc/config \
	 $(1)/usr/lib/acme

	$(INSTALL_CONF) ./files/acme.config $(1)/etc/config/acme
	$(INSTALL_BIN) ./files/run.sh $(1)/usr/lib/acme/run-acme
	$(INSTALL_BIN) ./files/acme.init $(1)/etc/init.d/acme
endef

$(eval $(call BuildPackage,acme-common))
