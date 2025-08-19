# SPDX-License-Identifier: GPL-2.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=age
PKG_VERSION:=1.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/FiloSottile/age/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=cefe9e956401939ad86a9c9d7dcf843a43b6bcdf4ee7d8e4508864f227a3f6f0

PKG_MAINTAINER:=Arnau Valls <vallsfustearnau@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/FiloSottile/age
GO_PKG_BUILD_PKG:=filippo.io/age/cmd/...
GO_PKG_LDFLAGS_X:=$(GO_PKG)/cmd.Version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/age
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=age file encryption
	URL:=https://docs.gitlab.com/runner
	DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/age/description
age is a simple, modern and secure file encryption tool, format, and Go library.

It features small explicit keys, no config options, and UNIX-style composability.
endef

$(eval $(call GoBinPackage,age))
$(eval $(call BuildPackage,age))

