#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=imx-uuc
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/nxp-imx/imx-uuc.git
PKG_SOURCE_DATE:=2024-12-18
PKG_SOURCE_VERSION:=25f65e10368aa07056f9536e88ed911ac7f38f99
PKG_MIRROR_HASH:=ba5462f5a1ec1d308545b4d1684c63551855eead7ee98f67c7c8e4ad2a8a56ae

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Michael Heimpold <mhei@heimpold.de>

include $(INCLUDE_DIR)/package.mk

define Package/imx-uuc/Default
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=https://github.com/nxp-imx/imx-uuc.git
  DEPENDS:=@TARGET_mxs
endef

define Package/sdimage
  $(call Package/imx-uuc/Default)
  TITLE:=Tool to install a bootstream on SD card/eMMC
endef

define Package/sdimage/description
  This package contains the 'sdimage' tool which can be used to write/update
  a bootstream on NXP i.MX23/28 devices. Such bootstreams are placed in a
  special partition on SD card/eMMC and need to be prefixed with an
  additional header. A typical bootstream is e.g. u-boot.sb.
endef

define Package/ufb
  $(call Package/imx-uuc/Default)
  TITLE:=On-target companion tool to interact with NXP's mfgtool.
endef

define Package/ufb/description
  This package contains the 'ufb' tool which acts
  as companion daemon to NXP's mfgtool on host side.
endef

define Build/Configure
endef

define Package/sdimage/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sdimage $(1)/usr/bin/sdimage
endef

define Package/ufb/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ufb $(1)/usr/bin/ufb
endef

$(eval $(call BuildPackage,sdimage))
$(eval $(call BuildPackage,ufb))
