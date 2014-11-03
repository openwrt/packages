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

PKG_NAME:=luci-app-bmx6
PKG_RELEASE:=3

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
PKG_LICENSE:=GPL-2.0+

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-bmx6
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:= bmx6 configuration, status and visualization module
  DEPENDS:=+luci-lib-json +luci-mod-admin-full +luci-lib-httpclient +bmx6
  MAINTAINER:= Pau Escrich <p4u@dabax.net>
endef

define Package/luci-app-bmx6/description
	bmx6 web application (status and configuration) for LuCi web interface
endef

define Package/luci-app-bmx6/conffiles
	/etc/config/luci-bmx6
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-bmx6/install
	$(CP) ./files/* $(1)/
	chmod 755 $(1)/www/cgi-bin/bmx6-info
endef

$(eval $(call BuildPackage,luci-app-bmx6))

