#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fail2ban
PKG_VERSION:=0.11.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/fail2ban/fail2ban/tar.gz/$(PKG_VERSION)?
PKG_HASH:=383108e5f8644cefb288537950923b7520f642e7e114efb843f6e7ea9268b1e0

PKG_MAINTAINER:=Gerald Kerma <gandalf@gk2.net>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

define Package/fail2ban
  SECTION:=net
  CATEGORY:=Network
  TITLE:=ban hosts that cause multiple authentication errors
  URL:=https://www.fail2ban.org/
  DEPENDS:= \
  +libinotifytools \
  +python3-pyinotify \
  +python3-light \
  +python3-dns \
  +python3-ctypes \
  +python3-distutils \
  +python3-email \
  +python3-logging \
  +python3-sqlite3 \
  +python3-urllib \
  +python3-setuptools
endef

define Package/fail2ban/description
  Fail2Ban scans log files like /var/log/auth.log and bans IP addresses conducting too many failed login attempts.
endef

define Package/fail2ban/conffiles
/etc/fail2ban/
/etc/config/fail2ban
endef

define Py3Package/fail2ban/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/fail2ban-server $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/fail2ban-client $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/fail2ban-regex $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/fail2ban $(1)/etc/config/fail2ban
	$(CP) ./files/etc/firewall.fail2ban $(1)/etc/firewall.fail2ban
		
	$(INSTALL_DIR) $(1)/etc/init.d
	$(CP) ./files/etc/init.d/fail2ban.init $(1)/etc/init.d/fail2ban

	$(INSTALL_DIR) $(1)/etc/fail2ban/
	$(CP) $(PKG_BUILD_DIR)/config/* $(1)/etc/fail2ban/

	$(INSTALL_DIR) $(1)/etc/fail2ban/fail2ban.d
	$(CP) ./files/etc/fail2ban.d/db.conf $(1)/etc/fail2ban/fail2ban.d/db.conf
	$(CP) ./files/etc/fail2ban.d/uci.conf $(1)/etc/fail2ban/fail2ban.d/uci.conf
endef

define Package/fail2ban/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	ln -s /usr/bin/python3 /usr/bin/fail2ban-python
	/etc/init.d/fail2ban enable
	/etc/init.d/fail2ban restart 2>/dev/null

	# unfortunately, UCI doesn't provide a nice way to add an anonymous section only if it doesn't already exist
	if ! uci show firewall | grep -q firewall.fail2ban; then
		name="$(uci add firewall include)"
		uci set "firewall.${name}.path=/etc/firewall.fail2ban"
		uci set "firewall.${name}.enabled=1"
		echo -e "Adding the following UCI config:\n $(uci changes)"
		uci commit
	fi
	/etc/init.d/firewall restart 2>/dev/null
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
