#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fail2ban
PKG_VERSION:=0.11.2
PKG_RELEASE:=1
PKGARCH:=ALL

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/fail2ban/fail2ban
PKG_MIRROR_HASH:=1899888a178e2a7d8b7234afcd96387559a7781fb4aa621c9288258e74753f47

PKG_MAINTAINER:=Gerald Kerma <gandalf@gk2.net>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE.txt

#PKG_BUILD_DEPENDS:=python python-setuptools

#include $(TOPDIR)/feeds/packages/lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-package.mk

#PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-$(PKG_NAME)-$(PKG_VERSION)
#PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/fail2ban
	SECTION:=net
	CATEGORY:=Network
	TITLE:=ban hosts that cause multiple authentication errors
	URL:=https://www.fail2ban.org/
	DEPENDS:= \
		+libinotifytools	\
		+python3-pyinotify	\
		+python3-light		\
		+python3-dns		\
		+python3-ctypes		\
		+python3-distutils	\
		+python3-email		\
		+python3-logging	\
		+python3-sqlite3	\
		+python3-urllib		\
		+python3-lib2to3	\
		+python3-setuptools
	VARIANT:=python3
endef

define Package/fail2ban/description
Fail2Ban scans log files like /var/log/auth.log and bans IP addresses conducting too many failed login attempts.
endef

define Package/fail2ban/conffiles
/etc/fail2ban/
/etc/config/fail2ban
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	cd $(PKG_BUILD_DIR) && ./fail2ban-2to3
endef

define Py3Package/fail2ban/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/fail2ban-server $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/fail2ban-client $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/fail2ban-regex $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/fail2ban/
	$(CP) $(PKG_BUILD_DIR)/config/* $(1)/etc/fail2ban/
	$(CP) ./files/etc/fail2ban/* $(1)/etc/fail2ban/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(CP) ./files/etc/init.d/fail2ban.init $(1)/etc/init.d/fail2ban

	$(INSTALL_DIR) $(1)/etc/fail2ban/fail2ban.d
	$(CP) ./files/etc/fail2ban/fail2ban.d/uci.conf $(1)/etc/fail2ban/fail2ban.d/uci.conf

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/fail2ban $(1)/etc/config/fail2ban
endef

define Package/fail2ban/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	ln -s /usr/bin/python3 /usr/bin/fail2ban-python
        /etc/init.d/fail2ban enable
        /etc/init.d/fail2ban restart 2>/dev/null
}
endef

define Package/fail2ban/prerm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
        /etc/init.d/fail2ban disable
        /etc/init.d/fail2ban stop
	rm /usr/bin/fail2ban-python
}
endef

$(eval $(call Py3Package,fail2ban))
$(eval $(call BuildPackage,fail2ban))
$(eval $(call BuildPackage,fail2ban-src))
