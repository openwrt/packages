#
# Copyright (C) 2026 Ricardo F. <r@rfmoz.eu>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tuptime
PKG_VERSION:=5.2.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rfmoz/tuptime/tar.gz/$(PKG_VERSION)?
PKG_HASH:=e7a1b695f037f87e309856c6678d8ee74d20ba3f1e4d2c1311b9982d612ba725

PKG_MAINTAINER:=Ricardo F. <r@rfmoz.eu>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

Build/Compile:=

define Package/tuptime
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Report historical system uptime statistics
  URL:=https://github.com/rfmoz/tuptime
  DEPENDS:=+python3-light +python3-sqlite3 +python3-logging
  USERID:=_tuptime=6500:_tuptime=6500
endef

define Package/tuptime/description
  Tuptime reports historical and statistical system uptime,
  keeping track of shutdowns, reboots, and system life.
endef

define Package/tuptime/conffiles
/etc/crontabs/_tuptime
endef

define Package/tuptime/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/tuptime $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/tuptime.init $(1)/etc/init.d/tuptime

	$(INSTALL_DIR) $(1)/etc/crontabs
	echo '*/5 * * * * /usr/bin/python3 /usr/bin/tuptime -q' > $(1)/etc/crontabs/_tuptime
endef

$(eval $(call BuildPackage,tuptime))
