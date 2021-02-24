include $(TOPDIR)/rules.mk

PKG_NAME:=cni
PKG_VERSION:=0.8.0
PKG_RELEASE:=3
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/containernetworking/$(PKG_NAME)/archive/v$(PKG_VERSION)
PKG_HASH:=df8afe3eeae3296ba33ca267041c42f13135c3a067bf2d932761bb02998247a6

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>, Paul Spooren <mail@aparcar.org>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/containernetworking/cni/
GO_PKG_BUILD_PKG:=github.com/containernetworking/cni/cnitool

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

PKG_USE_MIPS16:=0
GO_PKG_BUILD_VARS += GO111MODULE=auto

define Package/cni
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=cni
  URL:=https://github.com/containernetworking/cni
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/cni/description
  CNI (Container Network Interface), a Cloud Native Computing Foundation
  project, consists of a specification and libraries for writing plugins to
  configure network interfaces in Linux containers, along with a number of
  supported plugins. CNI concerns itself only with network connectivity of
  containers and removing allocated resources when the container is deleted.
  Because of this focus, CNI has a wide range of support and the specification
  is simple to implement.
endef

define Package/cni/install
	$(call GoPackage/Package/Install/Bin,$(1))
endef

$(eval $(call GoBinPackage,cni))
$(eval $(call BuildPackage,cni))
