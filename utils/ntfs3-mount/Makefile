include $(TOPDIR)/rules.mk

PKG_NAME:=ntfs3-mount
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/ntfs3-mount
	SECTION:=utils
	CATEGORY:=Utilities
	SUBMENU:=Filesystem
	TITLE:=NTFS mount script for NTFS read & write driver
	PKGARCH:=all
	DEPENDS:=+kmod-fs-ntfs3
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/ntfs3-mount/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) ./files/mount.ntfs $(1)/sbin
endef

$(eval $(call BuildPackage,ntfs3-mount))
