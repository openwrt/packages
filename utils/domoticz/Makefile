#
# Copyright © 2015 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

# These are automatically generated in the normal Domoticz build,
# from the git repository. We have to override it when we build
# from a tarball.
DOMOTICZ_APPHASH:=2e94eb6
DOMOTICZ_APPVERSION:=3674
DOMOTICZ_APPDATE:=1448110184

PKG_NAME:=domoticz
PKG_VERSION:=2.${DOMOTICZ_APPVERSION}
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=${DOMOTICZ_APPHASH}
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/domoticz/domoticz.git
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.gz

CMAKE_INSTALL:=1

PKG_INSTALL:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += -DCPACK_STRIP_FILES=1 -DVERBOSE=1 -DUSE_STATIC_BOOST=NO -DUSE_STATIC_LIBSTDCXX=NO -DUSE_BUILTIN_SQLITE=NO -DCMAKE_CXX_FLAGS_RELEASE=-O2

define Build/Prepare
	$(call Build/Prepare/Default)
	# Override the build information
	sed -i $(PKG_BUILD_DIR)/getgit.cmake \
		-e 's/^Gitversion_GET_REVISION.*/set(ProjectRevision $(DOMOTICZ_APPVERSION))/' \
		-e 's/^Gitversion_GET_HASH.*/set(ProjectHash $(DOMOTICZ_APPHASH))/' \
		-e 's/^Gitversion_GET_DATE.*/set(ProjectDate $(DOMOTICZ_APPDATE))/' \
		-e 's/^\(MATH(EXPR ProjectRevision.*\)/#\1/'
endef

define Package/domoticz/conffiles
/etc/config/domoticz
endef

define Package/domoticz
  TITLE:=Domoticz Home Automation
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libusb-compat +libcurl +libsqlite3 +boost-thread +boost-date_time +boost-system +libopenssl +zlib +libstdcpp
  URL:=http://www.domoticz.com/
  MAINTAINER:=David Woodhouse <dwmw2@infradead.org>
endef

define Package/domoticz/description
 Domoticz is a Home Automation System that lets you monitor and configure various devices like:
  Lights, Switches, various sensors/meters like Temperature, Rain, Wind, UV, Electra, Gas, Water and much more.
  Notifications/Alerts can be sent to any mobile device.
endef

define Package/domoticz/install
	$(INSTALL_DIR) $(1)/usr/share/domoticz
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/opt/domoticz/domoticz $(1)/usr/share/domoticz/
	$(CP) $(PKG_INSTALL_DIR)/opt/domoticz/www $(1)/usr/share/domoticz/

	$(INSTALL_DIR) $(1)/usr/share/domoticz/scripts/lua/
	$(CP) $(PKG_INSTALL_DIR)/opt/domoticz/scripts/lua/ $(1)/usr/share/domoticz/lua/

	$(INSTALL_DIR) $(1)/usr/bin/
	ln -sf ../share/domoticz/domoticz $(1)/usr/bin/domoticz

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/domoticz.init $(1)/etc/init.d/domoticz

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/domoticz.conf $(1)/etc/config/domoticz
endef

$(eval $(call BuildPackage,domoticz))
