#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=seafile-server
PKG_VERSION:=6.3.4
PKG_RELEASE:=6
PKG_LICENSE:=GPL-3.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/haiwen/seafile-server/tar.gz/v$(PKG_VERSION)-server?
PKG_HASH:=1ba4c641bad8d7592fd2592827e81470c88b8e802707d2b1e6d551c16d0da100
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-server
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../../lang/python/python-package.mk

# Check that the actual Makefile version-relase match the above.
$(eval $(shell awk '/^PKG_VERSION.*=/ { print "SEAHUB_" $$$$0 }' ../seafile-seahub/Makefile))
ifneq ($(PKG_VERSION),$(SEAHUB_PKG_VERSION))
    $(error $(if $(SEAHUB_PKG_VERSION), \
		Version mismatch between seafile-seahub ($(SEAHUB_PKG_VERSION)) and \
		seafile-server ($(PKG_VERSION)), \
		Could not get PKG_VERSION from seafile-seahub Makefile))
endif

define Package/seafile-server
    SECTION:=net
    CATEGORY:=Network
    TITLE:=Seafile server
    URL:=https://seafile.com/
    DEPENDS:=+libarchive +libopenssl +glib2 +libsearpc +seafile-ccnet +seafile-seahub +sqlite3-cli +python-mysql +python-urllib3 \
		+jansson +libevent2 +libevent2-openssl +zlib +libzdb +libsqlite3 +libmysqlclient +oniguruma \
		+libpthread +libuuid +bash +procps-ng +procps-ng-pkill +SEAFILE_FUSE_SUPPORT:libfuse $(ICONV_DEPENDS)
    MENU:=1
endef

define Package/seafile-server/config
	source "$(SOURCE)/Config.in"
endef

define Package/seafile-server/description
   Open source cloud storage with advanced features on privacy protection and teamwork.
endef

CONFIGURE_ARGS += --enable-python

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

PKG_BUILD_DEPENDS:=vala/host libevhtp

# This is required as python-package.mk overrides the default setting of having interlinking enabled
ifdef CONFIG_USE_MIPS16
	TARGET_CFLAGS += -minterlink-mips16
endif
TARGET_LDFLAGS += -Wl,-rpath-link=$(STAGING_DIR)/usr/lib -liconv \
		    -L$(STAGING_DIR)/usr/lib/mysql -lmysqlclient -lz -levent_openssl -levent

ifdef CONFIG_GCC_LIBSSP
TARGET_LDFLAGS += -lssp
endif

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
