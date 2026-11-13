# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2026 Amr Fateem <amr.fateem@yahoo.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=v2raya-core
PKG_VERSION:=2.5.13
PKG_RELEASE:=1

PKG_SOURCE:=v2rayA-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/v2rayA/v2rayA/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=20f03a9143231e2f04b74cdcb7125c6a44b450a4a28fac92b3e64c13916ec4d9
PKG_BUILD_DIR:=$(BUILD_DIR)/v2rayA-core-$(PKG_VERSION)/core

PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Amr Fateem <amr.fateem@yahoo.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/v2rayA/v2raya-core
GO_PKG_BUILD_PKG:=github.com/v2rayA/v2raya-core/main
GO_PKG_LDFLAGS_X:=main.Version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

# The core is pure Go.  CGO stays disabled on every target, including mips:
# this is the same configuration upstream uses for its release binaries.
GO_PKG_TARGET_VARS:=$(filter-out CGO_ENABLED=%,$(GO_PKG_TARGET_VARS)) CGO_ENABLED=0
GO_PKG_DEFAULT_LDFLAGS:=$(filter-out -linkmode external,$(GO_PKG_DEFAULT_LDFLAGS))

TAR_OPTIONS+= --strip-components 1
TAR_CMD=$(HOST_TAR) -C $(1)/.. $(TAR_OPTIONS)

define Package/v2raya-core
  TITLE:=v2raya_core - the merged xray-core used by v2rayA
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
  URL:=https://github.com/v2rayA/v2rayA
endef

define Package/v2raya-core/description
  v2raya_core combines xray-core with the MultiObservatory support and the
  extra protocols required by v2rayA 2.5.x.  The service and the core must
  always be installed at the same version.
endef

define Package/v2raya-core/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/main $(1)/usr/bin/v2raya_core
endef

$(eval $(call GoBinPackage,v2raya-core))
$(eval $(call BuildPackage,v2raya-core))
