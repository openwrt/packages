#
## Copyright (C) 2020, 2025 CZ.NIC z.s.p.o. (https://www.nic.cz/)
#
## This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
# #
#
include $(TOPDIR)/rules.mk

PKG_NAME:=mox-pkcs11
PKG_VERSION:=2.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://gitlab.nic.cz/turris/mox-pkcs11.git
PKG_MIRROR_HASH:=424b5247288310c6a71b7babed201dc153c58fca73241530254d2cbc84f1b4ef
PKG_SOURCE_VERSION:=v$(PKG_VERSION)

PKG_MAINTAINER:=CZ.NIC <packaging@turris.cz>
PKG_LICENSE:=GPL-3.0-or-later

include $(INCLUDE_DIR)/package.mk

define Package/mox-pkcs11
  TITLE:=MOX PKCS11
  DEPENDS:=@(TARGET_mvebu_cortexa53_DEVICE_ripe_atlas-v5||TARGET_mvebu_cortexa53_DEVICE_cznic_turris-mox) +libopenssl +libkeyutils
endef

define Package/mox-pkcs11/description
  Contains PKCS11 module that suppports Turris MOX internal ECDSA key
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) $(FPIC) -o $(PKG_BUILD_DIR)/libmox-pkcs11.so $(PKG_BUILD_DIR)/mox-pkcs11.c -lcrypto -lkeyutils -Wall -shared
endef

define Package/mox-pkcs11/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libmox-pkcs11.so $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/pkcs11
	$(LN) ../libmox-pkcs11.so $(1)/usr/lib/pkcs11/
endef

$(eval $(call BuildPackage,mox-pkcs11))
