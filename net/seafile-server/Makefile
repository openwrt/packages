#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=seafile-server
PKG_VERSION:=5.1.4
PKG_RELEASE=$(PKG_SOURCE_VERSION)-1
PKG_LICENSE:=GPL-3.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/haiwen/seafile.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=b9dc96ee845bb0148d9075aec597e6e07652cbdc
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
    DEPENDS:=+libarchive +libopenssl +glib2 +libsearpc +seafile-ccnet +seafile-seahub +sqlite3-cli +python-mysql +python-urllib3 \
		+jansson +libevent2 +libevent2-openssl +zlib +libzdb +libsqlite3 +libmysqlclient \
		+libpthread +libuuid +bash +procps-ng +procps-ng-pkill +SEAFILE_FUSE_SUPPORT:libfuse $(ICONV_DEPENDS)
    EXTRA_DEPENDS:=seafile-ccnet (=5.1.4-44f74fdc5160c1bf16a92e71d79b856763ddbc15-1), seafile-seahub (=5.1.4-1e1c02aa4f2a0256ffa29a28224aad2d678f43a0-1)
    MENU:=1
endef

define Package/seafile-server/config
	source "$(SOURCE)/Config.in"
endef

define Package/seafile-server/description
   Open source cloud storage with advanced features on privacy protection and teamwork.
endef

CONFIGURE_ARGS += --disable-client \
		    --enable-server \
		    --enable-python \
		    --disable-static-build \
		    --disable-server-pkg

ifeq ($(CONFIG_SEAFILE_FUSE_SUPPORT),y)
	CONFIGURE_ARGS += --enable-fuse
	TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/fuse
else
	CONFIGURE_ARGS += --disable-fuse
endif

ifeq ($(CONFIG_SEAFILE_CONSOLE_SUPPORT),y)
	CONFIGURE_ARGS += --enable-console
else
	CONFIGURE_ARGS += --disable-console
endif

ifeq ($(CONFIG_SEAFILE_RIAK_SUPPORT),y)
	CONFIGURE_ARGS += --enable-riak
else
	CONFIGURE_ARGS += --disable-riak
endif

PKG_BUILD_DEPENDS:=vala/host libevhtp

# This is required as python-package.mk overrides the default setting of having interlinking enabled
ifdef CONFIG_USE_MIPS16
	TARGET_CFLAGS += -minterlink-mips16
endif
TARGET_LDFLAGS += -Wl,-rpath-link=$(STAGING_DIR)/usr/lib -liconv \
		    -L$(STAGING_DIR)/usr/lib/mysql -lmysqlclient -lz -levent_openssl -levent

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
ifeq ($(CONFIG_SEAFILE_FUSE_SUPPORT),y)
	$(CP) $(PKG_BUILD_DIR)/scripts/seaf-fuse.sh $(1)/usr/share/seafile/seafile-server/
endif
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
   echo
   echo "*** In case you are upgrading seafile, please run the appropriate upgrade script"
   echo "*** manually before using the new version."
   echo "*** Upgrade scripts are located at \"/usr/share/seafile/seafile-server/upgrade\""
   echo
   echo "*** For more information, please read http://manual.seafile.com/deploy/upgrade.html"
fi
endef

$(eval $(call BuildPackage,seafile-server))
