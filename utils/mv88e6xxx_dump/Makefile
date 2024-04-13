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
PKG_MIRROR_HASH:=9b6d491933bee0dca79d5ef8b366beff796f90fdc27002a8b82ad8e4c56bd148
PKG_SOURCE_DATE:=2023.03.08
PKG_SOURCE_VERSION:=b4c5247ee8bb5512fb80081503aae183b35ed3c6

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
