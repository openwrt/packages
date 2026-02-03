# SPDX-Identifier-License: GPL-3.0-or-later
#
# Copyright (C) 2019 Elon Huang <elonhhuang@gmail.com>
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=rclone
PKG_VERSION:=1.72.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rclone/rclone/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=322c73932b533571880832c0e07abdf9492c7f329b7d1dcdbd2a195fa2635a77

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Elon Huang <elonhhuang@gmail.com> \
		Tianling Shen <cnsztl@immortalwrt.org>
PKG_CPE_ID:=cpe:/a:rclone:rclone

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/rclone/rclone
GO_PKG_EXCLUDES:=test
GO_PKG_LDFLAGS_X:= \
	github.com/rclone/rclone/fs.Version=v$(PKG_VERSION) \
	main.Version=v$(PKG_VERSION) \
	main.BuildUser=openwrt \
	main.BuildHost=openwrt

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/rclone/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=File Transfer
  TITLE:=rsync for cloud storage
  URL:=https://rclone.org
endef

define Package/rclone
  $(call Package/rclone/Default)
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle +fuse3-utils
  USERID:=rclone:rclone
endef

define Package/rclone-config
  $(call Package/rclone/Default)
  TITLE+= (Config Scripts)
  DEPENDS:=+rclone
endef

define Package/rclone/description
  Rclone ("rsync for cloud storage") is a command line program to sync
  files and directories to and from different cloud storage providers.
endef

define Package/rclone-config/conffiles
/etc/config/rclone
endef

define Package/rclone/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rclone $(1)/usr/bin/
endef

define Package/rclone-config/install
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) $(CURDIR)/files/rclone.config $(1)/etc/config/rclone
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/rclone.init $(1)/etc/init.d/rclone
endef

$(eval $(call GoBinPackage,rclone))
$(eval $(call BuildPackage,rclone))
$(eval $(call BuildPackage,rclone-config))
