#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=eventcat
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Nicholas Smith <nicholas@nbembedded.com>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/eventcat
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Event-driven network watchdog for OpenWRT
  DEPENDS:=+lua +libubus-lua +luasocket +libuci-lua +luci-lib-nixio +libubox-lua
endef

define Package/eventcat/description
EventCat is an event-driven network watchdog that monitors network connectivity and reacts to interface events. Configurable via UCI at /etc/config/eventcat.
endef

define Package/eventcat/conffiles
/etc/config/eventcat
endef

define Build/Compile
	# No compilation needed for Lua scripts
endef

define Package/eventcat/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/eventcat.lua $(1)/usr/bin/eventcat.lua

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/eventcat.init $(1)/etc/init.d/eventcat

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/eventcat.config $(1)/etc/config/eventcat
endef

$(eval $(call BuildPackage,eventcat))
