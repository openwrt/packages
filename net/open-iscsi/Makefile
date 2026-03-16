# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=open-iscsi
PKG_VERSION:=2.1.10
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/open-iscsi/open-iscsi
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_MIRROR_HASH:=934cfe18caf5de9a85e394d10731ee9fd104b47cebc6da05b5fed8b117acb3db

PKG_MAINTAINER:=Lucian CRISTIAN <lucian.cristian@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:open-iscsi_project:open-iscsi

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_FLAGS:=lto

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/open-iscsi
	SECTION:=net
	CATEGORY:=Network
	URL:=http://www.open-iscsi.com/
	TITLE:=iSCSI userland tools
	DEPENDS:=+libopenssl +open-isns +libmount +libkmod +kmod-iscsi-initiator
endef

define Package/open-iscsi/description
The Open-iSCSI project provides a high-performance, transport independent,
implementation of RFC 3720 iSCSI for Linux.
User space contains the entire control plane: configuration manager,
iSCSI Discovery, Login and Logout processing, connection-level error processing,
Nop-In and Nop-Out handling, etc.
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	$(SED)'s,/run,/var/run,g' $(PKG_BUILD_DIR)/libopeniscsiusr/idbm.c
	$(SED)'s,/run,/var/run,g' $(PKG_BUILD_DIR)/usr/initiator.h
endef

MESON_ARGS += \
	-Dno_systemd=true

define Package/open-iscsi/conffiles
/etc/iscsi/
endef

define Package/open-iscsi/postinst
#!/bin/sh
[ -x /usr/sbin/iscsi-gen-initiatorname ] && /usr/sbin/iscsi-gen-initiatorname || exit 0
endef

define Package/open-iscsi/install
	$(INSTALL_DIR) \
	 $(1)/etc/init.d $(1)/etc/iscsi \
	 $(1)/usr/lib $(1)/usr/sbin
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/iscsi/iscsid.conf $(1)/etc/iscsi/
	$(INSTALL_BIN) ./files/iscsi* $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/open-iscsi $(1)/etc/init.d/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/iscsi{adm,d,-iname,uio} $(1)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libopeniscsiusr.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,open-iscsi))
