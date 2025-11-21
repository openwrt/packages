# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=tgt
PKG_VERSION:=1.0.97
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/fujita/tgt/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=459a3ee133fbd850519cde15784664934d29e5dc9680f21142247746e62d9082

PKG_MAINTAINER:=Maxim Storchak <m.storchak@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_CPE_ID:=cpe:/a:zaal:tgt

PKG_BUILD_FLAGS:=no-mips16
PKG_INSTALL:=1

PKG_CONFIG_DEPENDS:=CONFIG_PACKAGE_tgt_without_aio

include $(INCLUDE_DIR)/package.mk

define Package/tgt
	SECTION:=net
	CATEGORY:=Network
	URL:=https://github.com/fujita/tgt
	TITLE:=userspace iSCSI target
	DEPENDS:=+libpthread +!PACKAGE_tgt_without_aio:libaio
endef

define Package/tgt/description
The Linux target framework (tgt) is a user space SCSI target framework
that supports the iSCSI and iSER transport protocols and that also
supports multiple methods for accessing block storage. Tgt consists of
user-space daemon and tools.
endef

define Package/tgt/config
	config PACKAGE_tgt_without_aio
	depends on PACKAGE_tgt
	bool "Build without AIO support"
	default n
	help
		Disable aio bs type, don't depend on libaio


	config PACKAGE_tgt_without_sheepdog
	depends on PACKAGE_tgt
	bool "Build without Sheepdog support"
	default y
	help
		Disable sheepdog bs type to save some space
endef

MAKE_FLAGS += WITHOUT_AIO=$(CONFIG_PACKAGE_tgt_without_aio) WITHOUT_SHEEPDOG=$(CONFIG_PACKAGE_tgt_without_sheepdog)

define Build/Compile
	$(call Build/Compile/Default,programs)
endef

define Package/tgt/conffiles
/etc/config/tgt
endef

define Package/tgt/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d $(1)/usr/sbin
	$(INSTALL_DATA) ./files/tgt.config $(1)/etc/config/tgt
	$(INSTALL_BIN) ./files/tgt.init $(1)/etc/init.d/tgt
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/tgt{d,adm} $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,tgt))
