# Copyright (C) 2014 - Eloi Carbó Solé (GSoC2014) 
# BGP/Bird integration with OpenWRT and QMP
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

BIRD:=bird6
PKG_NAME:=$(BIRD)-openwrt
PKG_RELEASE:=0.2
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
PKG_LICENSE:=GPL-3.0+
uci:=$(BIRD)-uci
luci:=luci-app-$(BIRD)


include $(INCLUDE_DIR)/package.mk

define Build/Prepare
endef
define Build/Compile
endef

define Package/$(uci)
  TITLE:=The BIRD UCI module
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  MAINTAINER:=Eloi Carbo <eloicaso@openmailbox.org>
  URL:=https://github.com/eloicaso/bird6-openwrt/
  DEPENDS:=+$(BIRD) +libuci +uci
endef

define Package/$(uci)/description
$(BIRD) UCI integration module
endef

define Package/$(uci)/install
	$(INSTALL_DIR) $(1)/etc/$(BIRD)/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_BIN) ./src/init.d/$(BIRD) $(1)/etc/$(BIRD)/init.d/
	$(CP) ./src/uci-defaults/$(uci)-install-init.d $(1)/etc/$(BIRD)/init.d/
	$(CP) ./src/config/$(BIRD) $(1)/etc/config/
endef

define Package/$(uci)/postinst
#!/bin/sh
if [ -z $${IPKG_INSTROOT} ]; then
    ( . /etc/bird6/init.d/bird6-uci-install-init.d ) && rm -f /etc/bird6/init.d/bird6-uci-install-init.d
fi
endef


$(eval $(call BuildPackage,$(uci)))



define Package/$(luci)
  TITLE:=LuCI support for $(BIRD)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  MAINTAINER:=Eloi Carbo <eloicaso@openmailbox.org>
  URL:=https://github.com/eloicaso/bird6-openwrt/
  DEPENDS:=+$(BIRD)-uci +luci-base
endef

define Package/$(luci)/description
$(BIRD) application for LuCI
endef

define Package/$(luci)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/$(BIRD)/
	$(CP) ./src/model/* $(1)/usr/lib/lua/luci/model/cbi/$(BIRD)/
	$(CP) ./src/controller/* $(1)/usr/lib/lua/luci/controller/
endef

$(eval $(call BuildPackage,$(luci)))
