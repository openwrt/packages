#    Copyright (C) 2011 Pau Escrich <pau@dabax.net>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
#    The full GNU General Public License is included in this distribution in
#    the file called "COPYING".

include $(TOPDIR)/rules.mk

PKG_NAME:=bmx6-luci
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/bmx6-luci
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=Applications
  TITLE:=bmx6 luci interface
# DEPENDS:=+bmx6 +bmx6-uci-config +luci-lib-json +luci-mod-admin-core +luci-lib-httpclient
  DEPENDS:=+luci-lib-json +luci-mod-admin-core +luci-lib-httpclient
endef

define Package/bmx6-luci/description
	bmx6 web interface for luci
endef

define Package/bmx6-luci/conffiles
	/etc/config/luci-bmx6
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/bmx6-luci/install
	$(CP) ./files/* $(1)/
	chmod 755 $(1)/www/cgi-bin/bmx6-info
endef

$(eval $(call BuildPackage,bmx6-luci))

