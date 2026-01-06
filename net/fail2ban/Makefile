# SPDX-License-Identifier: GPL-2.0-or-later
#
# Copyright (C) 2021-2022 Gerald Kerma
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fail2ban
PKG_VERSION:=1.1.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/fail2ban/fail2ban/tar.gz/$(PKG_VERSION)?
PKG_HASH:=474fcc25afdaf929c74329d1e4d24420caabeea1ef2e041a267ce19269570bae

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:fail2ban:fail2ban

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

define Package/fail2ban
  SECTION:=net
  CATEGORY:=Network
  TITLE:=ban hosts that cause multiple authentication errors
  URL:=https://www.fail2ban.org/
  DEPENDS:= \
  +nftables \
  +python3-light \
  +python3-ctypes \
  +python3-email \
  +python3-logging \
  +python3-sqlite3 \
  +python3-urllib \
  +python3-pkg-resources
endef

define Package/fail2ban/description
  Fail2Ban scans log files like /var/log/auth.log and bans IP addresses conducting too many failed login attempts.
endef

define Package/fail2ban/conffiles
/etc/fail2ban/
/etc/config/fail2ban
endef

define Build/Compile
	$(call Py3Build/Compile)
endef

define Py3Package/fail2ban/filespec
+|$(PYTHON3_PKG_DIR)
-|$(PYTHON3_PKG_DIR)/fail2ban/tests
endef

define Py3Package/fail2ban/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/fail2ban-server $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/fail2ban-client $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/fail2ban-regex $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/fail2ban.config $(1)/etc/config/fail2ban
	$(INSTALL_BIN) ./files/firewall.fail2ban $(1)/etc/firewall.fail2ban

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/fail2ban.init $(1)/etc/init.d/fail2ban

	$(INSTALL_DIR) $(1)/etc/fail2ban/
	$(CP) $(PKG_BUILD_DIR)/config/* $(1)/etc/fail2ban/

	$(INSTALL_DIR) $(1)/etc/fail2ban/fail2ban.d
	$(INSTALL_DATA) ./files/db.conf $(1)/etc/fail2ban/fail2ban.d/db.conf
	$(INSTALL_DATA) ./files/uci.conf $(1)/etc/fail2ban/fail2ban.d/uci.conf

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/fail2ban.defaults $(1)/etc/uci-defaults/99_fail2ban
endef

$(eval $(call Py3Package,fail2ban))
$(eval $(call BuildPackage,fail2ban))
$(eval $(call BuildPackage,fail2ban-src))
