#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libpam
PKG_VERSION:=1.2.0
PKG_RELEASE:=2

PKG_SOURCE:=Linux-PAM-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://www.linux-pam.org/library/
PKG_MD5SUM:=ee4a480d77b341c99e8b1375f8f180c0
PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_MAINTAINER:=Nikos Mavrogiannopoulos <n.mavrogiannopoulos@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/Linux-PAM-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/libpam/Default
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=the Linux-PAM libraries and modules.
  URL:=http://www.kernel.org/pub/linux/libs/pam
endef

define Package/libpam
$(call Package/libpam/Default)
  VARIANT:=nodb
  TITLE+= (no DB support)
endef

define Package/libpam-db
$(call Package/libpam/Default)
  VARIANT:=db
  TITLE+= (DB support)
  DEPENDS:=+libdb47
endef

define Package/libpam/description
	The Linux-PAM Pluggable Authentication Modules.
endef

Package/libpam-db/description=$(Package/libpam/description)


ifeq ($(BUILD_VARIANT),nodb)
 TARGET_CFLAGS += $(FPIC)
 define Build/Configure
	$(call Build/Configure/Default, \
		--enable-shared \
		--enable-static \
		--enable-pamlocking \
		--disable-prelude \
		--disable-lckpwdf \
		--disable-selinux \
		--disable-nls \
		--disable-rpath \
		--disable-nis \
		--disable-regenerate-docu \
		--enable-db=no \
	)
 endef
endif

ifeq ($(BUILD_VARIANT),db)
 define Build/Configure
	$(call Build/Configure/Default, \
		--enable-shared \
		--enable-static \
		--enable-pamlocking \
		--disable-prelude \
		--disable-lckpwdf \
		--disable-selinux \
		--disable-nls \
		--disable-rpath \
	)
 endef
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/lib
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/lib/* $(1)/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include
endef

define Package/libpam/install/Default
	$(INSTALL_DIR) $(1)/lib $(1)/lib/security $(1)/lib/security/pam_filter
	$(INSTALL_DIR) $(1)/etc $(1)/etc/pam.d
	$(CP) $(PKG_INSTALL_DIR)/lib/*.so* $(1)/lib/
	$(CP) $(PKG_INSTALL_DIR)/etc/* $(1)/etc/
	$(CP) ./files/* $(1)/etc/
endef

define Package/libpam/install
$(call Package/libpam/install/Default,$(1))
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/lib/security/*.so* $(1)/lib/security/
	$(CP) $(PKG_INSTALL_DIR)/lib/security/pam_filter/* $(1)/lib/security/pam_filter/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/* $(1)/usr/sbin/
endef

define Package/libpam-db/install
$(call Package/libpam/install/Default,$(1))
	$(CP) $(PKG_INSTALL_DIR)/lib/security/{pam_userdb.so,pam_unix.so} $(1)/lib/security/
endef

$(eval $(call BuildPackage,libpam))
$(eval $(call BuildPackage,libpam-db))
