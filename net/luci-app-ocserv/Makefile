#    Copyright (C) 2014 Nikos Mavrogiannopoulos
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

PKG_NAME:=luci-app-ocserv
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-ocserv
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:= OpenConnect VPN server configuration and status module
  DEPENDS:=+luci-lib-json +luci-lib-nixio +luci-mod-admin-full +ocserv
  MAINTAINER:= Nikos Mavrogiannopoulos <n.mavrogiannopoulos@gmail.com>
endef

define Package/luci-app-ocserv/description
	ocserv web module for LuCi web interface
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

# Fixme: How can we add <%+ocserv_status%> in view/admin_status/index.htm?
define Package/luci-app-ocserv/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,luci-app-ocserv))

