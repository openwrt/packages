include $(TOPDIR)/rules.mk

PKG_NAME:=efivarfs-mount
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=OSkari Rauta <oskari.rauta@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/efivarfs-mount
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Filesystem
  TITLE:=efivarfs mouting script
  DEPENDS:=@TARGET_x86_64 +mount-utils +kmod-fs-efivarfs
endef

define Package/efivarfs-mount/description
  Mounts efivarfs automaticly on boot as a init script
endef

define Build/Compile
endef

define Package/efivarfs-mount/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/efivarfs $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,efivarfs-mount))
