include $(TOPDIR)/rules.mk

PKG_NAME:=autopart
PKG_VERSION:=0.1
PKG_RELEASE:=$(AUTORELEASE)

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=GPL-2.0-or-later

include $(INCLUDE_DIR)/package.mk

define Package/autopart
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Disc
  TITLE:=Automatically initialize LVM partition
  DEPENDS:=+lvm2 +partx-utils +sfdisk
  PKGARCH=all
endef

define Package/autopart/description
 Automatically allocate the GPT partition for LVM and initialize it
 on first boot.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/autopart/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/autopart $(1)/etc/uci-defaults/30-autopart
endef

$(eval $(call BuildPackage,autopart))
