#
# Author: Tibor Dudlák
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tang
PKG_VERSION:=7
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/latchset/$(PKG_NAME)/releases/download/v$(PKG_VERSION)/
PKG_HASH:=fbe13e4e3103cd24cada7824b63e510cffd650832ecd075fd49b99475a4f9bfa

PKG_MAINTAINER:=Tibor Dudlák <tibor.dudlak@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

# This avoids generating man pages
CONFIGURE_VARS += ac_cv_prog_A2X=

define Package/tang
  SECTION:=utils
  TITLE:=tang v$(PKG_VERSION) - daemon for binding data to the presence of a third party
  DEPENDS:=+libhttp-parser +xinetd +jose +bash
  URL:=https://github.com/latchset/tang
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
