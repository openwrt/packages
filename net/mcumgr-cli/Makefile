# SPDX-License-Identifier: Apache-2.0
#
# Copyright (C) 2024

include $(TOPDIR)/rules.mk

PKG_NAME:=mcumgr-cli
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/apache/mynewt-mcumgr-cli.git
PKG_SOURCE_DATE:=2022-10-04
PKG_SOURCE_VERSION:=5c56bd24066c780aad5836429bfa2ecc4f9a944c
PKG_MIRROR_HASH:=7381f3f97e35ef57c0b515efa0d49606c8f4ad810fd00385c64d37a5e6cb88c5

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Bruce Cheung <bruce.cheung111@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/apache/mynewt-mcumgr-cli
GO_PKG_BUILD_PKG:=github.com/apache/mynewt-mcumgr-cli/mcumgr

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/mcumgr-cli
  SECTION:=net
  CATEGORY:=Network
  TITLE:=MCU Manager CLI
  URL:=https://github.com/apache/mynewt-mcumgr-cli
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/mcumgr-cli/description
  MCU Manager (mcumgr) is the application tool that enables a user
  to communicate with and manage remote devices running an mcumgr server.
  It supports firmware upgrades, file management, and device management
  over various transports including serial, BLE, and UDP.
endef

$(eval $(call GoBinPackage,mcumgr-cli))
$(eval $(call BuildPackage,mcumgr-cli))
