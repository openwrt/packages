#
# Copyright (C) 2022-2025 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=librespeed-cli
PKG_VERSION:=1.0.14
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/librespeed/speedtest-cli/tar.gz/v${PKG_VERSION}?
PKG_HASH:=3031e0f7babd7f9c51a1c49b95026d12532668455e8cc459049160f1bd525bf3

PKG_MAINTAINER:=Michal Vasilek <michal.vasilek@nic.cz>
PKG_LICENSE:=LGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/speedtest-cli-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/librespeed/speedtest-cli
# Without these the binary reports no name and no version at all, which leaves
# --version printing an empty string where the version belongs. The v prefix
# matches what the upstream release build produces, so the same version does
# not read differently depending on where the binary came from. BuildDate is
# left unset on purpose: the only value available here is a timestamp, and
# baking one in would make the build unreproducible.
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/defs.ProgName=$(PKG_NAME) \
	$(GO_PKG)/defs.ProgVersion=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/librespeed-cli
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Command line client for LibreSpeed
  URL:=https://github.com/librespeed/speedtest-cli
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/librespeed-cli/description
  LibreSpeed client for measuring internet speed from command line.
endef

define Package/librespeed-cli/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/speedtest-cli $(1)/usr/bin/librespeed-cli
endef

$(eval $(call GoBinPackage,librespeed-cli))
$(eval $(call BuildPackage,librespeed-cli))
