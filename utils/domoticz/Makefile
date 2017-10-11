#
# Copyright (C) 2016 - 2017  Stijn Tintel <stijn@linux-ipv6.be>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=domoticz
PKG_VERSION_MAJOR:=3
PKG_VERSION_PATCH:=8153
PKG_VERSION:=$(PKG_VERSION_MAJOR).$(PKG_VERSION_PATCH)
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/domoticz/domoticz/archive/$(PKG_VERSION)/$(PKG_SOURCE)
PKG_HASH:=5ea8f37f2ef900e9bd17b1b5375e75bfdec4f09001e3e2e0b647a260989d014c

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=License.txt

PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/domoticz
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Open Source Home Automation System
  URL:=http://domoticz.com/
  MAINTAINER:=Stijn Tintel <stijn@linux-ipv6.be>
  USERID:=domoticz=6144:domoticz=6144
  DEPENDS:= \
	+boost \
	+boost-date_time \
	+boost-system \
	+boost-thread \
	+libcurl \
	+libmosquittopp \
	+libopenssl \
	+libopenzwave \
	+libsqlite3 \
	+libstdcpp \
	+zlib
endef

define Package/domoticz/description
  Domoticz is a Home Automation System that lets you monitor and configure various devices like: Lights, Switches, various sensors/meters like Temperature, Rain, Wind, UV, Electra, Gas, Water and much more. Notifications/Alerts can be sent to any mobile device.
endef

CMAKE_OPTIONS += \
	-DCMAKE_BUILD_TYPE=Release \
	-DUSE_BUILTIN_MQTT=no \
	-DUSE_BUILTIN_SQLITE=no \
	-DUSE_STATIC_BOOST=no \
	-DUSE_STATIC_LIBSTDCXX=no \
	-DUSE_STATIC_OPENZWAVE=no \
	-DUSE_PYTHON=no

TARGET_CXXFLAGS+=-DWITH_GPIO

define Build/Prepare
	$(call Build/Prepare/Default)
	# Fix APPVERSION to suppress update popup
	sed -i 's/#define APPVERSION.*/#define APPVERSION $(PKG_VERSION_PATCH)/' \
		 $(PKG_BUILD_DIR)/appversion.default
	# Remove unwanted scripts
	cd $(PKG_BUILD_DIR)/scripts && rm -rf \
		buienradar_rain_example.pl \
		_domoticz_main* \
		download_update.sh \
		dzVents/{.gitignore,documentation,examples,generated_scripts} \
		dzVents/runtime/{integration-tests,misc/smoothing.xlsx,tests} \
		logrotate/ \
		lua_parsers/example* \
		lua/*demo.lua \
		python/ \
		readme.txt \
		restart_domoticz \
		templates/All.Python \
		update_domoticz
	# Remove *.md
	cd $(PKG_BUILD_DIR) && $(FIND) -name '*.md' -delete
endef

define Package/domoticz/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/hotplug.d/tty $(1)/etc/init.d
	$(INSTALL_BIN) ./files/domoticz.hotplug $(1)/etc/hotplug.d/tty/domoticz
	$(INSTALL_BIN) ./files/domoticz.init $(1)/etc/init.d/domoticz
	$(INSTALL_CONF) ./files/domoticz.config $(1)/etc/config/domoticz
	$(INSTALL_DIR) $(1)/usr/share/domoticz $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/Config $(1)/usr/share/domoticz/openzwave
	$(CP) $(PKG_INSTALL_DIR)/usr/scripts $(1)/usr/share/domoticz/
	$(CP) $(PKG_INSTALL_DIR)/usr/www $(1)/usr/share/domoticz/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/domoticz $(1)/usr/bin/domoticz
endef

define Package/domoticz/conffiles
/etc/config/domoticz
/var/lib/domoticz/
endef

$(eval $(call BuildPackage,domoticz))
