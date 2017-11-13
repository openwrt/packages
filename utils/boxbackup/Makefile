#
# Copyright (C) 2017 Val Kulkov <val.kulkov@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
#
#

include $(TOPDIR)/rules.mk

PKG_NAME:=boxbackup
PKG_SOURCE_DATE:=2017-10-18

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/boxbackup/boxbackup.git
PKG_SOURCE_VERSION:=24aca3fc618e36e2feb448bd7b5c05b31a064bd3
PKG_MIRROR_HASH:=ba6a76040c070b864f4d0057c160492eca522107dfa2e006df41abd1554b2161
PKG_MAINTAINER:=Val Kulkov <val.kulkov@gmail.com>

PKG_LICENSE:=GPL-2.0 BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.txt LICENSE-DUAL.txt LICENSE-GPL.txt COPYING.txt

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/boxbackup/Default
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=https://www.boxbackup.org/
  TITLE:=A client-server online backup system
endef

define Package/boxbackup/description/Default
Box Backup is an open source, completely automatic, on-line backup
system that supports both continuous and snapshot backups and secure
file transfer over an untrusted network.
endef

define Package/boxbackup-server
  $(call Package/boxbackup/Default)
  TITLE+= (server)
  USERID:=bbstored:bbstored
  DEPENDS:=+libopenssl +zlib +libstdcpp +coreutils-stat +openssl-util
endef

define Package/boxbackup-server/description
$(call Package/boxbackup/description/Default)
endef

define Package/boxbackup-client
  $(call Package/boxbackup/Default)
  TITLE+= (client)
  DEPENDS:=+libopenssl +zlib +libstdcpp +coreutils-stat +openssl-util
endef

define Package/boxbackup-client/description
$(call Package/boxbackup/description/Default)
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_VARS += ac_cv_have_decl_optreset=no

CONFIGURE_ARGS += \
	--with-random=/dev/urandom

config_directory=/etc/boxbackup

define Package/boxbackup-server/conffiles
$(config_directory)/bbstored.conf
$(config_directory)/raidfile.conf
$(config_directory)/bbstored/
endef

define Package/boxbackup-client/conffiles
$(config_directory)/bbackupd.conf
$(config_directory)/bbackupd/
endef

define Build/Prepare
$(call Build/Prepare/Default)
	( cd $(PKG_BUILD_DIR) ; \
		export TAR_TIMESTAMP=$$(basename $(PKG_BUILD_DIR) | sed 's/$(PKG_NAME)-//') ; \
		sed -i "s/USE_SVN_VERSION/$$$${TAR_TIMESTAMP}/" VERSION.txt ; \
		[ -f ./configure ] || ./bootstrap ; \
	)
endef

define Build/Install
	$(call Build/Install/Default,install install-backup-client)
	$(call Build/Install/Default,install install-backup-server)
endef

define Package/boxbackup-server/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/boxbackup/bbstored $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/bbstored $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/bbstoreaccounts $(1)/usr/sbin
	$(INSTALL_BIN) ./files/raidfile-config $(1)/usr/sbin
	$(INSTALL_BIN) ./files/bbstored-certs $(1)/usr/sbin
	$(INSTALL_BIN) ./files/bbstored-config $(1)/usr/sbin
	$(INSTALL_BIN) ./files/bbstored.init $(1)/etc/init.d/bbstored
	$(INSTALL_CONF) ./files/bbstored.conf.bb $(1)/etc/boxbackup/
	$(INSTALL_CONF) ./files/raidfile.conf.bb $(1)/etc/boxbackup/
endef

define Package/boxbackup-client/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/bbackupd $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/bbackupquery $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/bbackupctl $(1)/usr/sbin
	$(INSTALL_BIN) ./files/bbackupd.init $(1)/etc/init.d/bbackupd
	$(INSTALL_BIN) ./files/bbackupd-config $(1)/usr/sbin
endef

$(eval $(call BuildPackage,boxbackup-server))
$(eval $(call BuildPackage,boxbackup-client))

