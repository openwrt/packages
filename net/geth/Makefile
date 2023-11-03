#
# Copyright (C) 2018 Sartura Ltd.
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=go-ethereum
PKG_VERSION:=1.10.20
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ethereum/go-ethereum/tar.gz/v${PKG_VERSION}?
PKG_HASH:=15ff54f0a4444eb9faa7c1f6219d3a1db5d547178b4eef6679bb601abc681f9d

PKG_MAINTAINER:=Mislav Novakovic <mislav.novakovic@sartura.hr>
PKG_LICENSE:=GPL-3.0-or-later LGPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING COPYING.LESSER

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16
PKG_CONFIG_DEPENDS:=CONFIG_BUILD_NLS

GO_PKG:=github.com/ethereum/go-ethereum
GO_PKG_BUILD_PKG:=github.com/ethereum/go-ethereum/cmd/geth

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../../lang/golang/golang-package.mk

define Package/geth
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Ethereum Go client
  URL:=https://geth.ethereum.org/
  DEPENDS:=$(GO_ARCH_DEPENDS) $(ICONV_DEPENDS)
endef

define Package/geth/description
Ethereum is a decentralized platform that runs smart contracts, applications
that run exactly as programmed without possibility of downtime, censorship,
fraud or third party interference.
endef

TARGET_LDFLAGS += $(if $(ICONV_FULL),-liconv)

define Package/geth/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/geth.init $(1)/etc/init.d/geth
endef

$(eval $(call GoBinPackage,geth))
$(eval $(call BuildPackage,geth))
