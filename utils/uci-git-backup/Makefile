#
# Copyright (C) 2026 Mathias Rangger
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=uci-git-backup
PKG_VERSION:=1.2.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Mathias Rangger <mathias.rangger@gmail.com>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/uci-git-backup
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=Automatically back up UCI configuration to Git
	DEPENDS:=+git +git-http +openssh-client
endef

define Package/uci-git-backup/description
	Automatically commits and pushes watched UCI configuration to a remote Git
	repository whenever a watched config is committed. Includes manual connection
	testing and restore helpers for LuCI integration.
endef

define Package/uci-git-backup/conffiles
/etc/config/uci_git_backup
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/uci-git-backup/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/uci_git_backup.config $(1)/etc/config/uci_git_backup

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/uci-git-backup.init $(1)/etc/init.d/uci-git-backup

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/99-uci-git-backup $(1)/etc/uci-defaults/99-uci-git-backup

	$(INSTALL_DIR) $(1)/etc/uci-git-backup

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/uci-git-backup $(1)/usr/bin/uci-git-backup
	$(INSTALL_BIN) ./files/uci-git-test $(1)/usr/bin/uci-git-test
	$(INSTALL_BIN) ./files/uci-git-list $(1)/usr/bin/uci-git-list
	$(INSTALL_BIN) ./files/uci-git-restore $(1)/usr/bin/uci-git-restore
endef

$(eval $(call BuildPackage,uci-git-backup))
