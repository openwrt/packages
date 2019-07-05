#    Copyright © 2011 Pau Escrich <pau@dabax.net>
#    Contributors Roger Pueyo Centelles <roger.pueyo@guifi.net>
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

PKG_NAME:=luci-app-bmx7
PKG_RELEASE:=0.1-alpha

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
PKG_LICENSE:=GPL-2.0+

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-bmx7
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:= LuCI support for BMX7
  DEPENDS:=+luci-lib-json +luci-mod-admin-full +bmx7 +bmx7-json
  MAINTAINER:= Roger Pueyo <roger.pueyo@guifi.net> and Pau Escrich <p4u@dabax.net>
endef

define Package/luci-app-bmx7/description
	LuCI application for web-based configuration and visualization of the BMX7 routing daemon
endef

define Package/luci-app-bmx7/conffiles
	/etc/config/luci-bmx7
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-bmx7/install
	$(CP) ./files/* $(1)/
	chmod 755 $(1)/www/cgi-bin/bmx7-info
endef

$(eval $(call BuildPackage,luci-app-bmx7))

