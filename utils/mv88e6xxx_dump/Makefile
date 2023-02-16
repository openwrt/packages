#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mv88e6xxx_dump
PKG_RELEASE:=1

PKG_FIXUP:=autoreconf

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/lunn/mv88e6xxx_dump
PKG_MIRROR_HASH:=2f1bce89212a10be89e106398ccc2f7eedcc1a7299bf8a1a05b3baf061f779f5
PKG_SOURCE_DATE:=2022.03.29
PKG_SOURCE_VERSION:=a3f713f99e0004d17d9282e0cb253505b9ca35b6

PKG_MAINTAINER:=Etienne Champetier <champetier.etienne@gmail.com>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/mv88e6xxx_dump
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=https://github.com/lunn/mv88e6xxx_dump
  TITLE:=mv88e6xxx_dump
  DEPENDS:=@(TARGET_ath79||TARGET_imx||TARGET_kirkwood||TARGET_mvebu||TARGET_qoriq) +libmnl
endef

define Package/mv88e6xxx_dump/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mv88e6xxx_dump $(1)/usr/bin/
endef

$(eval $(call BuildPackage,mv88e6xxx_dump))
