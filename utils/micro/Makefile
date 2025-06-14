# This is free software, licensed under the MIT License.

include $(TOPDIR)/rules.mk

PKG_NAME:=micro
PKG_VERSION:=2.0.14
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/zyedidia/micro/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=40177579beb3846461036387b649c629395584a4bbe970f61ba7591bd9c0185a

PKG_MAINTAINER:=Gregory Gullin <gargullia@proton.me>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/zyedidia/micro
GO_PKG_LDFLAGS_X:=\
	main.Build=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../packages/lang/golang/golang-package.mk

define Package/micro
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Modern and intuitive terminal-based text editor
  URL:=https://micro-editor.github.io/
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Build/Compile
  $(call GoPackage/Build/Compile)
endef

define Package/micro/description
  micro is a terminal-based text editor that aims to be easy to use and intuitive,
  while also taking advantage of the capabilities of modern terminals.
  It comes as a single, batteries-included, static binary with no dependencies;
  you can download and use it right now!
endef

define Package/micro/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/micro $(1)/usr/bin/micro
endef

$(eval $(call BuildPackage,micro))
