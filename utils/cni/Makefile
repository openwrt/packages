include $(TOPDIR)/rules.mk

PKG_NAME:=cni
PKG_VERSION:=1.1.2
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/containernetworking/$(PKG_NAME)/archive/v$(PKG_VERSION)
PKG_HASH:=7d4bcaf83acdd54b3dc216f7aa5b5e1b32cb797d9c6af601a2c26b97470ed743

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>, Paul Spooren <mail@aparcar.org>, Oskari Rauta <oskari.rauta@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/containernetworking/cni/
GO_PKG_BUILD_PKG:=github.com/containernetworking/cni/cnitool

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

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
