# SPDX-License-Identifier: MIT
#
# Copyright (C) ForestVPN.com

include $(TOPDIR)/rules.mk

PKG_NAME:=fvpn
PKG_VERSION:=0.2.1-post.1
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/forestvpn/cli/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=34583aca56237484f6b820bd4ffb3ad82cdbc90af6e3dd0b577e25f6509ce8b1

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Anatolio Nikiforidis <anatoly@forestvpn.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/forestvpn/cli
GO_PKG_BUILD_PKG:=$(GO_PKG)/main
GO_PKG_LDFLAGS_X:=$(GO_PKG).appVersion=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/fvpn
  TITLE:=ForestVPN - Fast, secure, and modern VPN.
  SECTION:=net
  CATEGORY:=Network
  URL:=https://forestvpn.com
  DEPENDS:=$(GO_ARCH_DEPENDS) +wireguard-tools
endef

define Package/fvpn/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/main $(1)/usr/bin/fvpn
endef

$(eval $(call BuildPackage,fvpn))
