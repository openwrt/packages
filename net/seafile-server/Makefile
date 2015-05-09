#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=seafile-server
PKG_VERSION:=4.1.2
PKG_RELEASE=$(PKG_SOURCE_VERSION)
PKG_LICENSE:=GPL-3.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/haiwen/seafile.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=c0166019c712e2e1d5e532fd5f7401b1b72db6d8
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/seafile-server
    SECTION:=net
    CATEGORY:=Network
    TITLE:=Seafile server
    MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
    URL:=http://seafile.com/
    DEPENDS:=+shadow-useradd +libarchive +libopenssl +glib2 +libsearpc +seafile-ccnet +seafile-seahub \
		+sqlite3-cli +python-mysql +jansson +libevent2 +libevent2-openssl +zlib +libzdb +libsqlite3 \
		+libmysqlclient +libevhtp +libpthread +libuuid \
		+bash +sudo +procps +procps-pkill $(ICONV_DEPENDS)
    EXTRA_DEPENDS:=seafile-ccnet (=4.1.2-a73109f09af4ecc49cdc4c57cdde51b38e15c31a), seafile-seahub (=4.1.2-3fb1288f920de03a4e2e6a06b60671ce98971742)
endef

define Package/seafile-server/description
   Open source cloud storage with advanced features on privacy protection and teamwork.
endef

define Package/seafile-server/conffiles
/etc/config/seafile
endef

CONFIGURE_ARGS += --disable-riak \
		    --disable-client \
		    --disable-fuse \
		    --enable-server \
		    --enable-python \
		    --disable-static-build \
		    --disable-server-pkg \
		    --disable-console

PKG_BUILD_DEPENDS:=vala/host \
		    libsearpc/host

TARGET_LDFLAGS += -Wl,-rpath-link=$(STAGING_DIR)/usr/lib -liconv \
		    -L$(STAGING_DIR)/usr/lib/mysql -lmysqlclient -lz

define Package/seafile-server/install
	$(INSTALL_DIR) $(1)/usr/{bin,lib}
	$(INSTALL_DIR) $(1)/usr/lib/python2.7/site-packages
	$(INSTALL_DIR) $(1)/usr/share/seafile/seafile-server/runtime
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/python2.7/site-packages/seafile/ $(1)/usr/lib/python2.7/site-packages/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/python2.7/site-packages/seaserv/ $(1)/usr/lib/python2.7/site-packages/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libseafile.so* $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/scripts/seaf-gc.sh $(1)/usr/share/seafile/seafile-server/
	$(CP) $(PKG_BUILD_DIR)/scripts/setup-seafile-mysql.py $(1)/usr/share/seafile/seafile-server/
	$(CP) $(PKG_BUILD_DIR)/scripts/setup-seafile-mysql.sh $(1)/usr/share/seafile/seafile-server/
	$(CP) $(PKG_BUILD_DIR)/scripts/sqlite2mysql.py $(1)/usr/share/seafile/seafile-server/
	$(CP) $(PKG_BUILD_DIR)/scripts/sqlite2mysql.sh $(1)/usr/share/seafile/seafile-server/
	$(CP) $(PKG_BUILD_DIR)/scripts/upgrade/ $(1)/usr/share/seafile/seafile-server/
	$(INSTALL_BIN) ./files/seafile.init $(1)/etc/init.d/seafile
	$(CP) ./files/seafile.conf $(1)/etc/config/seafile
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/include/seafile/ $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libseafile.pc $(1)/usr/lib/pkgconfig/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libseafile.so* $(1)/usr/lib/
endef

define Package/seafile-server/postinst
#!/bin/sh

if ! id -u seafile >/dev/null 2>&1; then
    useradd seafile -d "/usr/share/seafile" -s /bin/sh; fi

chown -R seafile:seafile /usr/share/seafile/
chmod -R o-rwx /usr/share/seafile/

if [ ! -d "/usr/share/seafile/seafile-data" ]
then
   echo "*** Installation completed, running configuration script..."
   /etc/init.d/seafile setup

   if [ $$? -ne 0 ]
   then
      echo
      echo "*** ERROR: Configuration failed. Please fix the issues if any and re-run the script using the command below:"
      echo "*** \"/etc/init.d/seafile setup\""
   fi

   echo
   echo "*** NOTE: you need to create an admin account before using Seafile."
   echo "*** Please run \"/etc/init.d/seafile create_admin\" to do so."
else
   echo "*** WARNING: it seems you are upgrading from an older version."
   echo "*** If so, please run the appropriate upgrade script before using the new version of Seafile."
   echo "*** Upgrade scripts are located at \"/usr/share/seafile/seafile-server/upgrade\""
   echo
   echo "*** For more information, please read http://manual.seafile.com/deploy/upgrade.html"
   exit
fi

/etc/init.d/seafile enable
/etc/init.d/seafile restart
endef

define Package/seafile-server/prerm
#!/bin/sh
/etc/init.d/seafile stop
endef

$(eval $(call BuildPackage,seafile-server))
