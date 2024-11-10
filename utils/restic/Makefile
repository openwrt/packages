include $(TOPDIR)/rules.mk

PKG_NAME:=restic
PKG_VERSION:=0.17.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/restic/restic/tar.gz/v${PKG_VERSION}?
PKG_HASH:=bf0dd73edfae531c24070e2e7833938613f7b179ed165e6b681098edfdf286c8

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tom Stöveken <tom@naaa.de>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/restic/restic/
GO_PKG_BUILD_PKG:=github.com/restic/restic/cmd/restic/
GO_PKG_LDFLAGS_X:=main.version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/restic
  TITLE:=restic backup program
  URL:=http://github.com/restic/restic
  DEPENDS:=$(GO_ARCH_DEPENDS)
  SECTION:=utils
  CATEGORY:=Utilities
endef

define Package/restic/description
restic is a backup program that is fast, efficient and secure. It supports the
three major operating systems (Linux, macOS, Windows) and a few smaller ones
(FreeBSD, OpenBSD).
endef

$(eval $(call GoBinPackage,restic))
$(eval $(call BuildPackage,restic))
