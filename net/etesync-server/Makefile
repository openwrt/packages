include $(TOPDIR)/rules.mk

PKG_NAME:=etesync-server
PKG_VERSION:=0.2.0
PKG_RELEASE:=1
PKG_LICENSE:=AGPLv3

PKG_SOURCE:=server-skeleton-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/etesync/server-skeleton/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=435aef6f8f33f82b13dbb99f00c16fa92743194aedb0b4a88ee51001e51244f1

PKG_BUILD_DIR:=$(BUILD_DIR)/etesync-server-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

define Package/etesync-server
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=End-to-End Encrypted Secure Data Sync 
	URL:=https://www.etesync.com/
	DEPENDS:=+nginx-ssl +django2-etesync-journal
	VARIANT:=python3
	USERID:=etesync=44312
endef

define Package/etesync-uwsgi
	$(call Package/etesync-server)
	TITLE+=using uWSGI.
	DEPENDS+=+uwsgi-python-plugin
endef

define Package/etesync-server/description
	End-to-End Encrypted Secure Data Sync
endef

define Package/etesync-uwsgi/description
	$(call Package/etesync-server/description)
	using uWSGI.
endef

define Py3Build/Compile/help
	$(call Build/Compile/HostPy3RunTarget, \
		cd $(PKG_INSTALL_DIR)/etesync-server, \
		$1, \
		$(PYTHON3_PKG_SETUP_VARS))
endef

define Py3Build/Compile
	$(if $(HOST_PYTHON3_PACKAGE_BUILD_DEPENDS),
		$(call Build/Compile/HostPy3PipInstall,$(HOST_PYTHON3_PACKAGE_BUILD_DEPENDS))
	)
	$(INSTALL_DIR) $(PKG_INSTALL_DIR)/etesync-server/etesync_server/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/etesync_server/* \
		$(PKG_INSTALL_DIR)/etesync-server/etesync_server/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/manage.py \
		$(PKG_INSTALL_DIR)/etesync-server
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/requirements.txt \
		$(PKG_INSTALL_DIR)/etesync-server
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/etesync-server.ini \
		$(PKG_INSTALL_DIR)/etesync-server
	$(call Py3Build/Compile/help,-m pip install -r requirements.txt)
	$(call Py3Build/Compile/help,./manage.py migrate --noinput)
	$(call Py3Build/Compile/help,./manage.py shell -c \
		"from django.contrib.auth.models import User; \
			User.objects.create_superuser('root', '', 'root')")
	$(call Py3Build/Compile/help,./manage.py collectstatic --noinput)
endef

define Py3Package/etesync-server/filespec
	+|/etesync-server/etesync_server
endef

define Py3Package/etesync-uwsgi/filespec
	$(call Py3Package/etesync-server/filespec)
endef

define Py3Package/etesync-server/install
	$(INSTALL_DIR) $(1)/etesync-server
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etesync-server/etesync-server.ini \
		$(1)/etesync-server/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etesync-server/db.sqlite3 \
		$(1)/etesync-server/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/etesync-server/manage.py \
		$(1)/etesync-server/
	$(SED) 's_#!.*_#!/usr/bin/python3_g' $(1)/etesync-server/manage.py
	$(INSTALL_DIR) $(1)/www/etesync_server/static
	$(CP) $(PKG_INSTALL_DIR)/etesync-server/static/* \
		$(1)/www/etesync_server/static
	$(LN) /www/etesync_server/static $(1)/etesync-server/static
	$(INSTALL_DIR) $(1)/etc/nginx/conf.d/
endef

define Py3Package/etesync-uwsgi/install
	$(call Py3Package/etesync-server/install, $(1))
	$(INSTALL_CONF) ./files/uwsgi-nginx.conf \
		$(1)/etc/nginx/conf.d/etesync.conf
	$(INSTALL_DIR) $(1)/etc/uwsgi/sites
	$(INSTALL_CONF) ./files/uwsgi.ini \
		$(1)/etc/uwsgi/sites/etesync.ini
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/uwsgi.init \
		$(1)/etc/init.d/etesync
endef


define Package/etesync/conffiles
/etesync-server/etesync-server.ini
/etc/nginx/conf.d/etesync.conf
endef

define Package/etesync-uwsgi/conffiles
$(Package/etesync/conffiles)
/etc/uwsgi/sites/etesync.ini
endef

#TODO preserve db.sqlite3?!

define Package/etesync-server/postinst
#!/bin/sh
chown -R etesync:nogroup /etesync-server || exit 1
chown etesync:nogroup /etc/uwsgi/sites/etesync.ini || exit 1
#TODO: change ip to servername: ## 
for ip in $$(ifconfig  | grep 'inet addr:' | grep -v '127.0.0.1' \
	| cut -d: -f2 | awk '{ print $$1}')
do  
	cd /etc/nginx/conf.d/ || exit 1
	grep "server_name.*$$ip" etesync.conf \
	|| sed -i "s/server_name /server_name $$ip /g" etesync.conf \
	|| exit 1
	cd /etesync-server || exit 1
	grep "^allowed_host.* = $$ip" etesync-server.ini \
	|| sed -i "/^\[allowed_hosts\]$$/a allowed_host = $$ip" \
		etesync-server.ini \
	|| exit 1
done 
if [ -n "$$(pgrep etesync)" ]; then
	/etc/init.d/etesync reload
else
	/etc/init.d/etesync start
fi
if [ ! -f "/etesync-server/ssl.key" ]; then
	NGINX_KEY=/etesync-server/ssl.key
	NGINX_CER=/etesync-server/ssl.cer
	OPENSSL_BIN=/usr/bin/openssl
	PX5G_BIN=/usr/sbin/px5g
	# Prefer px5g for certificate generation (existence evaluated last)
	GENKEY_CMD=""
	UNIQUEID=$$(dd if=/dev/urandom bs=1 count=4 | hexdump -e '1/1 "%02x"')
	[ -x "$$OPENSSL_BIN" ] && GENKEY_CMD="$$OPENSSL_BIN req -x509 -nodes"
	[ -x "$$PX5G_BIN" ] && GENKEY_CMD="$$PX5G_BIN selfsigned"
	[ -n "$$GENKEY_CMD" ] && {
		$$GENKEY_CMD \
			-days 730 -newkey rsa:2048 -keyout "$${NGINX_KEY}.new" -out "$${NGINX_CER}.new" \
			-subj /C="ZZ"/ST="Somewhere"/L="Unknown"/O="OpenWrt""$$UNIQUEID"/CN="OpenWrt"
		sync
		mv "$${NGINX_KEY}.new" "$${NGINX_KEY}"
		mv "$${NGINX_CER}.new" "$${NGINX_CER}"
	}
fi 
if [ -n "$$(pgrep nginx)" ]; then
	/etc/init.d/nginx reload
else
	/etc/init.d/nginx start
fi
endef

define Package/etesync-uwsgi/postinst
$(call Package/etesync-server/postinst)
endef

# $(eval $(call Py3Package,etesync-server))
# $(eval $(call BuildPackage,etesync-server))

$(eval $(call Py3Package,etesync-uwsgi))
$(eval $(call BuildPackage,etesync-uwsgi))

# define Package/etesync-gunicorn
# 	$(call Package/etesync-server)
# 	TITLE+=using gunicorn.
# 	DEPENDS+=+gunicorn3
# endef
# 
# define Package/etesync-gunicorn/description
# 	$(call Package/etesync-server/description)
# 	using gunicorn.
# endef
# 
# define Package/etesync-gunicorn/install
# 	$(call Package/etesync-server/install, $(1))
# endef
# 
# define Package/etesync-gunicorn/postinst
# $(call Package/etesync-server/postinst)
# endef
# 
# $(eval $(call Py3Package,etesync-gunicorn))
# $(eval $(call BuildPackage,etesync-gunicorn))
