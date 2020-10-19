include $(TOPDIR)/rules.mk

PKG_NAME:=etesync-server
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


define Package/etesync-server
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=End-to-End Encrypted Secure Data Sync
	URL:=https://www.etesync.com/
	DEPENDS:=+nginx-ssl +python3-light +python3-django \
		+python3-django-restframework +python3-drf-nested-routers \
		+python3-django-cors-headers +python3-django-etesync-journal \
		+uwsgi +uwsgi-python3-plugin +uwsgi-syslog-plugin
	USERID:=etesync=44312
endef


define Package/etesync-server/description
	End-to-End Encrypted Secure Data Sync
endef


Build/Compile:=:


define Py3Package/etesync-server/install
	$(INSTALL_DIR) $(1)/www/etesync/static/

	$(INSTALL_DIR) $(1)/etc/uci-defaults/
	$(CP) ./files/81_setup-etesync-server $(1)/etc/uci-defaults/

	$(INSTALL_DIR) $(1)/etc/nginx/conf.d/
	$(INSTALL_CONF) ./files/etesync.locations $(1)/etc/nginx/conf.d/

	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) ./files/uci.cfg $(1)/etc/config/etesync_server

	$(INSTALL_DIR) $(1)/usr/share/etesync-server/templates/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/templates/* \
		$(1)/usr/share/etesync-server/templates/

	$(INSTALL_DIR) $(1)/usr/share/etesync-server/etesync_server/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/manage.py \
		$(1)/usr/share/etesync-server/

	$(INSTALL_DATA) $(PKG_BUILD_DIR)/etesync_server/* \
		$(1)/usr/share/etesync-server/etesync_server/

	$(LN) /var/etc/etesync-server/etesync-server.ini \
		$(1)/usr/share/etesync-server/
	#init creates /var/etc/etesync-server/etesync-server.ini from uci.cfg

	$(INSTALL_DIR) $(1)/etc/uwsgi/vassals/
	$(INSTALL_CONF) ./files/uwsgi.ini \
		$(1)/etc/uwsgi/vassals/etesync-server.available

	$(LN) /var/etc/etesync-server/uwsgi.ini \
		$(1)/etc/uwsgi/vassals/etesync-server.ini
	#init links etesync-server.available /var/etc/etesync-server/uwsgi.ini

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/uwsgi.init $(1)/etc/init.d/etesync-server
endef

Py3Package/etesync-server/filespec:=


define Package/etesync-server/postrm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0
rmdir --ignore-fail-on-non-empty /usr/share/etesync-server/etesync_server
[ "$${PKG_UPGRADE}" = "1" ] && exit 0
rm -r /www/etesync/static
rmdir /www/etesync
exit 0
endef


define Package/etesync-server/conffiles
/etc/config/etesync_server
/etc/nginx/conf.d/etesync.locations
/etc/uwsgi/vassals/etesync-server.available
endef


$(eval $(call Py3Package,etesync-server))
$(eval $(call BuildPackage,etesync-server))
$(eval $(call BuildPackage,etesync-server-src))
