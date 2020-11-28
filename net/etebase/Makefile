include $(TOPDIR)/rules.mk

PKG_NAME:=etebase
PKG_VERSION:=0.3.0
PKG_RELEASE:=3

PKG_SOURCE:=etesync-server-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/etesync/server/archive/v$(PKG_VERSION)
PKG_HASH:=d0728effa898a8b7afb4ce7439e0d0fd46bc819008925f21788d7e113435b579

PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Peter Stadler <peter.stadler@student.uibk.ac.at>

PKG_BUILD_PARALLEL:=1
PYTHON3_PKG_BUILD:=0

PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk


define Package/etebase
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=End-to-End Encrypted Secure Data Sync
	URL:=https://www.etesync.com/
	DEPENDS:=+nginx-ssl +python3-light +python3-django \
		+python3-django-restframework +python3-drf-nested-routers \
		+python3-django-cors-headers +python3-django-etesnc-journal \
		+uwsgi +uwsgi-python3-plugin +uwsgi-syslog-plugin
	USERID:=etebase=44313
endef


define Package/etebase/description
	End-to-End Encrypted Secure Data Sync
endef


Build/Compile:=:


define Py3Package/etebase/install
	# OpenWrt specific:
	$(INSTALL_DIR) $(1)/etc/uci-defaults/
	$(CP) ./files/81_setup-etebase $(1)/etc/uci-defaults/

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/uwsgi.init $(1)/etc/init.d/etebase

	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) ./files/uci.cfg $(1)/etc/config/etebase

	# Server configuration:
	$(INSTALL_DIR) $(1)/etc/nginx/conf.d/
	$(INSTALL_CONF) ./files/etebase.locations $(1)/etc/nginx/conf.d/

	$(INSTALL_DIR) $(1)/etc/uwsgi/vassals/
	$(INSTALL_CONF) ./files/uwsgi.ini $(1)/etc/uwsgi/vassals/etebase.available
	#init links etebase.available /var/etc/etebase/uwsgi.ini:
	$(LN) /var/etc/etebase/uwsgi.ini $(1)/etc/uwsgi/vassals/etebase.ini

	# Upstream application:
	$(INSTALL_DIR) $(1)/usr/share/etebase/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/manage.py $(1)/usr/share/etebase/
	#init creates /var/etc/etebase/server.ini from uci.cfg:
	$(LN) /var/etc/etebase/server.ini $(1)/usr/share/etebase/etesync-server.ini

	$(INSTALL_DIR) $(1)/usr/share/etebase/etesync_server/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/etesync_server/* $(1)/usr/share/etebase/etesync_server/

	$(INSTALL_DIR) $(1)/usr/share/etebase/templates/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/templates/* $(1)/usr/share/etebase/templates/

	$(INSTALL_DIR) $(1)/www/etebase/static/
endef


Py3Package/etebase/filespec:=


define Package/etebase/postrm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0
rmdir --ignore-fail-on-non-empty /usr/share/etebase/etebase
[ "$${PKG_UPGRADE}" = "1" ] && exit 0
rm -r /www/etebase/static
rmdir /www/etebase
exit 0
endef


define Package/etebase/conffiles
/etc/config/etebase
/etc/nginx/conf.d/etebase.locations
/etc/uwsgi/vassals/etebase.available
endef


$(eval $(call Py3Package,etebase))
$(eval $(call BuildPackage,etebase))
$(eval $(call BuildPackage,etebase-src))
