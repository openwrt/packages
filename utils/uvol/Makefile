include $(TOPDIR)/rules.mk

PKG_NAME:=uvol
PKG_VERSION:=1.2
PKG_RELEASE:=1

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=GPL-2.0-or-later

include $(INCLUDE_DIR)/package.mk

define Package/autopart
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Disc
  TITLE:=Automatically initialize LVM partition
  DEPENDS:=+lvm2 +partx-utils +sfdisk +e2fsprogs +mkf2fs +f2fsck
  PKGARCH=all
endef

define Package/autopart/description
 Automatically allocate and initialize a partition for LVM on first boot.
endef

define Package/uvol
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Disc
  TITLE:=OpenWrt UBI/LVM volume abstraction
  DEPENDS:=+blockd +ucode +ucode-mod-fs +ucode-mod-math +ucode-mod-uci +ucode-mod-ubus +rpcd
  PKGARCH=all
endef

define Package/uvol/description
  'uvol' is a tool to automate storage volume handling on embedded
  devices in a generic way.
  Depending on what is available, 'uvol' will use either UBI or LVM2
  as storage backends and transparently offer identical operations on
  top of them.

  Also install the 'autopart' package to easily make use of 'uvol' on
  block-storage based devices.

  Volume operations are also exposed as ubus object 'uvol' through an
  rpcd exec plugin, using the same backends and locks as the command
  line tool.

  Examples:
  uvol create example_volume_1 268435456 rw
  uvol up example_volume_1
  uvol device example_volume_1

  uvol create example_volume_2 9812733 ro
  cat example_volume_2.squashfs | uvol write example_volume_2 9812733
  uvol up example_volume_2
  uvol device example_volume_2
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/autopart/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/autopart.defaults $(1)/etc/uci-defaults/30-autopart
endef

define Package/uvol/install
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/usr/lib/uvol/backends $(1)/usr/sbin $(1)/usr/libexec/rpcd
	$(INSTALL_BIN) ./files/uvol.init $(1)/etc/init.d/uvol
	$(INSTALL_DATA) ./files/blockdev_common.uc $(1)/usr/lib/uvol/
	$(INSTALL_DATA) ./files/common.uc $(1)/usr/lib/uvol/
	$(INSTALL_DATA) ./files/mount.uc $(1)/usr/lib/uvol/
	$(INSTALL_DATA) ./files/lvm.uc $(1)/usr/lib/uvol/backends/
	$(INSTALL_DATA) ./files/ubi.uc $(1)/usr/lib/uvol/backends/
	$(INSTALL_BIN) ./files/uvol $(1)/usr/sbin
	$(SED) 's/@PKG_VERSION@/$(PKG_VERSION)/g' $(1)/usr/sbin/uvol
	$(INSTALL_BIN) ./files/uvol-rpcd $(1)/usr/libexec/rpcd/uvol
endef

define Package/uvol/postinst
#!/bin/sh
[ -n "$$IPKG_INSTROOT" ] || /etc/init.d/rpcd reload
endef

$(eval $(call BuildPackage,autopart))
$(eval $(call BuildPackage,uvol))
