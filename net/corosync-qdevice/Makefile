# Copyright (C) 2025-2026 S Shaikh <sshaikh@hotmail.com>
# Copyright (C) 2026 Sven Kirmess <sven.kirmess@kzone.ch>

include $(TOPDIR)/rules.mk

PKG_NAME:=corosync-qdevice
PKG_VERSION:=3.0.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/corosync/corosync-qdevice/releases/download/v$(PKG_VERSION)/
PKG_HASH:=c2821329ed1efd6bf8f82e2878f75ca66889439d27c788785fd0ccc972ac307c
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_BUILD_DEPENDS:=nss corosync

PKG_MAINTAINER:=S Shaikh <sshaikh@hotmail.com>, Sven Kirmess <sven.kirmess@kzone.ch>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/corosync-qdevice
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Corosync QNetd - quorum device daemon
  URL:=https://github.com/corosync/corosync-qdevice
  DEPENDS:=+libcorosync +libnss +nss-utils +bash
endef

define Package/corosync-qdevice/description
  corosync-qnetd daemon providing an additional vote to Corosync/Proxmox
  clusters, allowing a 2-node cluster to maintain quorum when one node fails.

  NOTE: Proxmox VE users need openssh-sftp-server installed on this
  OpenWrt device before running 'pvecm qdevice setup' on the Proxmox node.
  It can be removed afterwards.
endef

CONFIGURE_ARGS += --with-bash=/bin/bash

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/share/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/pkgconfig/corosync-qdevice.pc $(1)/usr/share/pkgconfig
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/* $(1)/usr/sbin
endef

define Package/corosync-qdevice/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/* $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/corosync-qdevice.init $(1)/etc/init.d/corosync-qdevice
endef

define Package/corosync-qdevice/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ] && ! [ -f "/etc/corosync/qnetd/nssdb/cert9.db" ]; then
	/usr/bin/corosync-qnetd-certutil -i
fi
endef

$(eval $(call BuildPackage,corosync-qdevice))
