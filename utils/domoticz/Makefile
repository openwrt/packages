#
# Copyright (C) 2016 - 2017  Stijn Tintel <stijn@linux-ipv6.be>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=domoticz
PKG_VERSION_MAJOR:=3
PKG_VERSION_PATCH:=9571
PKG_COMMIT:=dfb39a9e739a0a07ab865577ed44e0b6aa9e7bdc
PKG_VERSION:=$(PKG_VERSION_MAJOR).$(PKG_VERSION_PATCH)
PKG_RELEASE:=1

ifeq ($(PKG_COMMIT),)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/domoticz/domoticz/archive/$(PKG_VERSION)/$(PKG_SOURCE)
else
PKG_SOURCE:=$(PKG_NAME)-$(PKG_COMMIT).tar.gz
PKG_SOURCE_URL:=https://github.com/domoticz/domoticz/archive/$(PKG_COMMIT)/$(PKG_SOURCE)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_COMMIT)
endif
PKG_HASH:=7e77a8ea87216f65c2f279535eb43d957e22ca14ccebfb1ef2054f9bc797a5c3

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
	-DUSE_OPENSSL_STATIC=no \
	-DUSE_PYTHON=no \
	-DWITH_LIBUSB=no

TARGET_CFLAGS+=-flto
TARGET_CXXFLAGS+=-DWITH_GPIO -flto

define Build/Prepare
	$(call Build/Prepare/Default)
	# Fix APPVERSION/APPDATE since we don't build from a git tree
	sed -i 's/#define APPVERSION.*/#define APPVERSION $(PKG_VERSION_PATCH)/' \
		 $(PKG_BUILD_DIR)/appversion.default
	COMMITDATE=`tar tvfz $(DL_DIR)/$(PKG_SOURCE) --full-time | sed 's/.* \(20..-..-.. ..:..:..\) domoticz-.*/\1/;q'`; \
	COMMITTS=`date --date="$$$${COMMITDATE}" +%s`; \
	sed -i "s/#define APPDATE.*/#define APPDATE $$$${COMMITTS}/" $(PKG_BUILD_DIR)/appversion.default
ifneq ($(PKG_COMMIT),)
	sed -i "s/#define APPHASH.*/#define APPHASH \"$(shell echo $(PKG_COMMIT) | cut -c1-8)\"/" $(PKG_BUILD_DIR)/appversion.default
endif
	# Remove unwanted scripts
	cd $(PKG_BUILD_DIR)/scripts && rm -rf \
		buienradar_rain_example.pl \
		_domoticz_main* \
		download_update.sh \
		dzVents/{.gitignore,documentation,examples,generated_scripts,data} \
		dzVents/runtime/{integration-tests,misc/smoothing.xlsx,tests} \
		logrotate/ \
		lua_parsers/example* \
		lua/*demo.lua \
		python/ \
		readme.txt \
		restart_domoticz \
		templates/All.Python \
		update_domoticz \
		domoticz.conf
	# Remove *.md
	cd $(PKG_BUILD_DIR) && $(FIND) -name '*.md' -delete
endef

define Package/domoticz/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/hotplug.d/tty $(1)/etc/init.d $(1)/etc/domoticz
	$(INSTALL_BIN) ./files/domoticz.hotplug $(1)/etc/hotplug.d/tty/domoticz
	$(INSTALL_BIN) ./files/domoticz.init $(1)/etc/init.d/domoticz
	$(INSTALL_CONF) ./files/domoticz.config $(1)/etc/config/domoticz
	$(INSTALL_DIR) $(1)/usr/share/domoticz $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/dzVents $(1)/usr/share/domoticz/dzVents
	$(CP) $(PKG_INSTALL_DIR)/usr/Config $(1)/usr/share/domoticz/Config
	$(CP) $(PKG_INSTALL_DIR)/usr/scripts $(1)/etc/domoticz/scripts
	ln -sf /var/lib/domoticz/dzVents/generated_scripts $(1)/etc/domoticz/scripts/dzVents
	ln -sf /var/lib/domoticz/dzVents/data $(1)/etc/domoticz/scripts/dzVents
	$(CP) $(PKG_INSTALL_DIR)/usr/www $(1)/usr/share/domoticz/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/domoticz $(1)/usr/bin/domoticz
	# compress static web content
	find $(1)/usr/share/domoticz/www -name "*.css" -exec gzip -9 {} \;
	find $(1)/usr/share/domoticz/www -name "*.js" -exec gzip -9 {} \;
	find $(1)/usr/share/domoticz/www -name "*.html" -exec sh -c 'grep -q "<\!--#embed" {} || gzip -9 {}' \;
endef

define Package/domoticz/conffiles
/etc/config/domoticz
/var/lib/domoticz/
/etc/domoticz/
endef

$(eval $(call BuildPackage,domoticz))
