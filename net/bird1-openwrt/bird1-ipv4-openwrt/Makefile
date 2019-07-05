# Copyright (C) 2014-2017  Eloi Carbo <eloicaso@openmailbox.org>
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

BIRD := bird4
BIRD_PKG := bird1-ipv4
PKG_NAME := $(BIRD_PKG)-openwrt
PKG_VERSION := 0.3
PKG_RELEASE := 1
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
PKG_LICENSE := GPL-3.0+
uci := $(BIRD_PKG)-uci
luci := luci-app-$(BIRD_PKG)

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
endef
define Build/Compile
endef

define Package/$(uci)
  TITLE:=The BIRD UCI module (v1.6) (IPv4)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  MAINTAINER:=Eloi Carbo <eloicaso@openmailbox.org>
  URL:=https://github.com/eloicaso/bird-openwrt/
  DEPENDS:=+$(BIRD_PKG) +libuci +uci
endef

define Package/$(uci)/description
$(BIRD_PKG) UCI integration module
endef

define Package/$(uci)/conffiles
	/etc/config/$(BIRD)
endef

define Package/$(uci)/install
	$(INSTALL_DIR) $(1)/etc/$(BIRD)/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/$(BIRD)/filters
	$(INSTALL_DIR) $(1)/etc/$(BIRD)/functions
	$(INSTALL_BIN) ./src/init.d/$(BIRD)* $(1)/etc/$(BIRD)/init.d/
	$(CP) ./src/uci-defaults/* $(1)/etc/$(BIRD)/init.d/
	$(INSTALL_CONF) ./src/config/$(BIRD) $(1)/etc/config/
endef

define Package/$(uci)/postinst
#!/bin/sh
    if [ -z "$${IPKG_INSTROOT}" ]; then
        ( . /etc/$(BIRD)/init.d/bird-uci-install-init.d $(BIRD) ) && rm -f /etc/$(BIRD)/init.d/bird-uci-install-init.d
        ( . /etc/$(BIRD)/init.d/99-relocate-filters $(BIRD) ) && rm -f /etc/$(BIRD)/init.d/99-relocate-filters
        if [ -f /etc/sysupgrade.conf ] && ! grep $(BIRD) /etc/sysupgrade.conf; then
            echo /etc/config/$(BIRD) >> /etc/sysupgrade.conf
            echo /etc/$(BIRD)/filters/ >> /etc/sysupgrade.conf
            echo /etc/$(BIRD)/functions/ >> /etc/sysupgrade.conf
        fi
    fi
endef

$(eval $(call BuildPackage,$(uci)))

define Package/$(luci)
  TITLE:=LuCI support for $(BIRD_PKG)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  MAINTAINER:=Eloi Carbo <eloicaso@openmailbox.org>
  URL:=https://github.com/eloicaso/bird-openwrt/
  DEPENDS:=+$(BIRD_PKG)-uci +luci-base
endef

define Package/$(luci)/description
$(BIRD) application for LuCI
endef

define Package/$(luci)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/$(BIRD)/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/$(BIRD)/
	$(CP) ./src/model/* $(1)/usr/lib/lua/luci/model/cbi/$(BIRD)/
	$(CP) ./src/controller/* $(1)/usr/lib/lua/luci/controller/
	$(CP) ./src/view/* $(1)/usr/lib/lua/luci/view/$(BIRD)/
endef

$(eval $(call BuildPackage,$(luci)))
