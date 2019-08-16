#
# Copyright 2019 NXP
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=eds-bootstrap-enroll
PKG_VERSION:=lsdk-1903
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/NXP/qoriq-eds-bootstrap.git
PKG_SOURCE_VERSION:=385ec26acec4e1dc891c1d0e63ed577485a85f46
PKG_MIRROR_HASH:=4245eb260c0fbde2ec870ba50346004c968ad3729ae7cbfa334ca1db821d4598

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/bootstrap-enroll
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Edgescale for edge computing
  TITLE:=Bootstrap certificate enroll tool
  DEPENDS:=@(arm||aarch64) +bash +curl +dnsmasq
endef

define Build/Compile
endef

define Package/bootstrap-enroll/install
	$(INSTALL_DIR) $(1)/usr/local/edgescale/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(LINUX_KARCH)/bootstrap-enroll $(1)/usr/local/edgescale/bin
endef

$(eval $(call BuildPackage,bootstrap-enroll))
