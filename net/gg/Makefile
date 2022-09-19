# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=gg
PKG_VERSION:=0.2.11
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/mzz2017/gg/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=8e15f2419570bbe8a9dd8cd524c2641e2c8dcb469dfed1702cb335c85162e34a

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/mzz2017/gg
GO_PKG_LDFLAGS_X:=$(GO_PKG)/cmd.Version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/gg
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A command-line tool for one-click proxy
  URL:=https://github.com/mzz2017/gg
  DEPENDS:=@(aarch64||arm||x86_64) +ca-bundle
endef

define Package/gg/description
  gg is a command-line tool for one-click proxy in your research and
  development.

  You can just add gg before another command to redirect its traffic
  to your proxy without installing v2ray or anything else.
  Usage example: gg python -m pip install torch.
endef

define Package/gg/conffiles
/root/.config/gg/config.toml
/root/.ggconfig.toml
/etc/ggconfig.toml
endef

$(eval $(call GoBinPackage,gg))
$(eval $(call BuildPackage,gg))
