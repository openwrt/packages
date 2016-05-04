#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=seafile-server
PKG_VERSION:=5.1.1
PKG_RELEASE=$(PKG_SOURCE_VERSION)-3
PKG_LICENSE:=GPL-3.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/haiwen/seafile.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=5a8677a3acdde748caa387adfc054da64f2a24ea
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
$(call include_mk, python-package.mk)

define Package/seafile-server
    SECTION:=net
    CATEGORY:=Network
    TITLE:=Seafile server
    MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
    URL:=http://seafile.com/
    DEPENDS:=+libarchive +libopenssl +glib2 +libsearpc +seafile-ccnet +seafile-seahub +sqlite3-cli +python-mysql \
		+jansson +libevent2 +libevent2-openssl +zlib +libzdb +libsqlite3 +libmysqlclient +libevhtp \
		+libpthread +libuuid +bash +procps-ng +procps-ng-pkill $(ICONV_DEPENDS)
    EXTRA_DEPENDS:=seafile-ccnet (=5.1.1-6d94fdc4296d542a5552039dc13a67c3448e8b13-1), seafile-seahub (=5.1.1-95f762f396c81f840fe658ab983df53784083bb1-1), libevhtp (>=1.2.10)
endef

define Package/seafile-server/description
   Open source cloud storage with advanced features on privacy protection and teamwork.
endef

CONFIGURE_ARGS += --disable-riak \
		    --disable-client \
		    --disable-fuse \
		    --enable-server \
		    --enable-python \
		    --disable-static-build \
		    --disable-server-pkg \
		    --disable-console

PKG_BUILD_DEPENDS:=vala/host

TARGET_LDFLAGS += -Wl,-rpath-link=$(STAGING_DIR)/usr/lib -liconv \
		    -L$(STAGING_DIR)/usr/lib/mysql -lmysqlclient -lz

define Package/seafile-server/conffiles
/etc/config/seafile
endef

define Package/seafile-server/install
	$(INSTALL_DIR) $(1)/usr/{bin,lib}
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(INSTALL_DIR) $(1)/usr/share/seafile/seafile-server
	$(INSTALL_DIR) $(1)/usr/share/seafile/conf
	$(INSTALL_DIR) $(1)/etc/{config,init.d}
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/seafile/ $(1)$(PYTHON_PKG_DIR)/
	$(CP) $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/seaserv/ $(1)$(PYTHON_PKG_DIR)/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libseafile.so* $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/scripts/seaf-gc.sh $(1)/usr/share/seafile/seafile-server/
	$(CP) $(PKG_BUILD_DIR)/scripts/seaf-fsck.sh $(1)/usr/share/seafile/seafile-server/
	$(CP) $(PKG_BUILD_DIR)/scripts/setup-seafile-mysql.py $(1)/usr/share/seafile/seafile-server/
	$(CP) $(PKG_BUILD_DIR)/scripts/setup-seafile-mysql.sh $(1)/usr/share/seafile/seafile-server/
	$(CP) $(PKG_BUILD_DIR)/scripts/sqlite2mysql.py $(1)/usr/share/seafile/seafile-server/
	$(CP) $(PKG_BUILD_DIR)/scripts/sqlite2mysql.sh $(1)/usr/share/seafile/seafile-server/
	$(CP) $(PKG_BUILD_DIR)/scripts/check_init_admin.py $(1)/usr/share/seafile/seafile-server/
	$(CP) $(PKG_BUILD_DIR)/scripts/upgrade/ $(1)/usr/share/seafile/seafile-server/
	$(CP) ./files/seafile.conf $(1)/etc/config/seafile
	$(INSTALL_BIN) ./files/seafile.init $(1)/etc/init.d/seafile
	$(INSTALL_BIN) ./files/seahub.init $(1)/etc/init.d/seahub
	find $(1) -name "*\.pyc" -o -name "*\.pyo" | xargs rm -f
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) $(PKG_INSTALL_DIR)/usr/include/seafile/ $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libseafile.pc $(1)/usr/lib/pkgconfig/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libseafile.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/seafile/ $(1)$(PYTHON_PKG_DIR)/
	$(CP) $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/seaserv/ $(1)$(PYTHON_PKG_DIR)/
endef

define Package/seafile-server/postinst
#!/bin/sh
[ ! -f /etc/init.d/seafile ] && exit 0

if [ ! -d /usr/share/seafile/seafile-data ]
then
   echo "*** Installation completed, running configuration script..."
   /etc/init.d/seafile setup

   if [ $$? -ne 0 ]
   then
      echo
      echo "*** ERROR: Configuration failed. Please fix the issues if any and re-run the script using the command below:"
      echo "*** \"/etc/init.d/seafile setup\""
   fi
else
   echo "*** seafile-data directory already exists."
   echo "*** In case you are upgrading seafile, please run the appropriate upgrade script"
   echo "*** manually before using the new version of Seafile."
   echo "*** Upgrade scripts are located at \"/usr/share/seafile/seafile-server/upgrade\""
   echo
   echo "*** For more information, please read http://manual.seafile.com/deploy/upgrade.html"
fi
endef

$(eval $(call BuildPackage,seafile-server))
