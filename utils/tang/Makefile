#
# Author: Tibor Dudlák
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tang
PKG_VERSION:=6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/latchset/$(PKG_NAME)/releases/download/v$(PKG_VERSION)/
PKG_HASH:=1df78b48a52d2ca05656555cfe52bd4427c884f5a54a2c5e37a7b39da9e155e3

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/tang
  SECTION:=utils
  TITLE:=tang v$(PKG_VERSION) - daemon for binding data to the presence of a third party
  DEPENDS:=+libhttp-parser +xinetd +jose +bash
  URL:=https://github.com/latchset/tang
  MAINTAINER:=Tibor Dudlák <tibor.dudlak@gmail.com>
endef

define Package/tang/description
	Tang is a small daemon for binding data to the presence of a third party.
endef

define Package/tang/conffiles
/etc/xinetd.d/tangdx
/usr/share/tang/db/
endef

define Package/tang/install
	$(INSTALL_DIR)	$(1)/usr/libexec
	$(INSTALL_DIR)	$(1)/etc/xinetd.d/
	$(INSTALL_BIN)	$(PKG_INSTALL_DIR)/usr/lib/tangd*	$(1)/usr/libexec/
	$(INSTALL_BIN)	./files/tangdw				$(1)/usr/libexec/
	$(CP)		./files/tangdx				$(1)/etc/xinetd.d/
endef

define Package/tang/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	mkdir -p /usr/share/tang/db && mkdir -p /usr/share/tang/cache
	KEYS=$(find /usr/share/tang/db/ -name "*.jw*" -maxdepth 1 | wc -l)
	if [ "${KEYS}" = "0" ]; then # if db is empty generate new key pair
		/usr/libexec/tangd-keygen /usr/share/tang/db/
	elif [ "${KEYS}" = "1" ]; then # having 1 key should not happen
		(>&2 echo "Please check the Tang's keys in /usr/share/tang/db \
and regenate cache using /usr/libexec/tangd-update script.")
	else
		/usr/libexec/tangd-update /usr/share/tang/db/ /usr/share/tang/cache/
	fi
	(cat /etc/services | grep -E "tangd.*8888\/tcp") > /dev/null \
		|| echo -e "tangd\t\t8888/tcp" >> /etc/services
fi
endef

$(eval $(call BuildPackage,tang))
