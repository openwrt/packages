# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=micro
PKG_VERSION:=2.0.15
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/zyedidia/micro/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=612c775321c268c8f9e1767505ff378bca9b9ab66f5c41b69ecb2464ecf15084

PKG_MAINTAINER:=Gregory Gullin <garuwex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE LICENSE-THIRD-PARTY

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/zyedidia/micro/v2
GO_PKG_LDFLAGS_X:=$(GO_PKG)/internal/util.Version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/micro
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Editors
  TITLE:=Modern and intuitive terminal-based text editor
  URL:=https://micro-editor.github.io/
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/micro/description
  micro is a terminal-based text editor that aims to be easy to use and intuitive,
  while also taking advantage of the capabilities of modern terminals.
  It comes as a single, batteries-included, static binary with no dependencies;
  you can download and use it right now!
endef

define Package/micro/conffiles
/root/.config/micro/
endef

$(eval $(call GoBinPackage,micro))
$(eval $(call BuildPackage,micro))
