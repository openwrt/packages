include $(TOPDIR)/rules.mk

PKG_NAME:=cgroupfs-mount
PKG_VERSION:=1.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/tianon/cgroupfs-mount/tar.gz/${PKG_VERSION}?
PKG_HASH:=d6c8aff7af59c7d0082ee3018c97f73b0421e81a49bb28ad9f66a36da5cd6ec7

PKG_MAINTAINER:=Gerard Ryan <G.M0N3Y.2503@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/cgroupfs-mount
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=cgroup mount scripts
  DEPENDS:=@KERNEL_CGROUPS +mount-utils
  MENU:=1
endef

define Package/cgroupfs-mount/description
Simple scripts to properly mount the cgroupfs hierarchy, especially structured for Debian packaging
endef

Build/Compile=# Nothing to compile, just install the scripts

define Package/cgroupfs-mount/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cgroupfs-mount $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cgroupfs-umount $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/cgroupfs-mount.init $(1)/etc/init.d/cgroupfs-mount
endef

$(eval $(call BuildPackage,cgroupfs-mount))
