# Copyright 2013-2016 Daniel Dickinson <lede@daniel.thecshore.com>
#
# MIT License

include $(TOPDIR)/rules.mk

PKG_NAME:=config-backup
PKG_VERSION:=1
PKG_RELEASE:=1
PKG_MAINTAINER:=Daniel Dickinson <lede@daniel.thecshore.com>
PKG_LICENSE:=MIT

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)-$(PGK_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
   SECTION:=utils
   CATEGORY:=Utilities
   TITLE:=Configuration backup scripts
endef

define Package/$(PKG_NAME)/description
A small script to make backing up router configuration
over SSH easy.  One would use a command such as
ssh root@router "/usr/sbin/config+data-backup" >router-backup.tar.gz
to backup the same configs as sysupgrade, plus the overlay
and the /data directory if it exists.  One can also use
ssh root@router "/usr/sbin/config-backup" >config-backup.tar.gz
to backup the same things as sysupgrade or LuCI backup.
HINT: To get a list packages try
ssh root@router "opkg list_installed" >packages.lst
endef

define Build/Prepare
	true
endef

define Build/Compile
	true
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/libexec/config-backup $(1)/usr/sbin
	$(INSTALL_BIN) ./files/usr/libexec/config-backup/* $(1)/usr/libexec/config-backup
	$(INSTALL_BIN) ./files/usr/sbin/config-backup $(1)/usr/sbin/
	ln -sf config-backup $(1)/usr/sbin/config+data-backup
endef

$(eval $(call BuildPackage,config-backup))

