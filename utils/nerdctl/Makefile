include $(TOPDIR)/rules.mk

PKG_NAME:=nerdctl
PKG_VERSION:=2.0.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/containerd/nerdctl/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=50118ed245f814ac39fe4598ba0cc5e401f820ba7260d706d544daea6d1c9d56

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Luca Barbato <lu_zero@gentoo.org>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/containerd/nerdctl
GO_PKG_LDFLAGS_X:=$(GO_PKG)/pkg/version.Version=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/nerdctl
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=contaiNERD CTL - Docker-compatible CLI for containerd
  URL:=https://containerd.io
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/nerdctl/description
  Docker-compatible CLI for containerd, with support for Compose, Rootless,
  eStargz, OCIcrypt, IPFS, ...
endef

$(eval $(call GoBinPackage,nerdctl))
$(eval $(call BuildPackage,nerdctl))
