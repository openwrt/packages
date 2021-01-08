include $(TOPDIR)/rules.mk

PKG_NAME:=containerd
PKG_VERSION:=1.4.3
PKG_RELEASE:=3
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/containerd/containerd/tar.gz/v${PKG_VERSION}?
PKG_HASH:=bc6d9452c700af0ebc09c0da8ddba55be4c03ac8928e72ca92d98905800c8018
PKG_SOURCE_VERSION:=269548fa27e0089a8b8278fc4fc781d7f65a939b

PKG_MAINTAINER:=Gerard Ryan <G.M0N3Y.2503@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/containerd/containerd

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/containerd
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=containerd container runtime
  URL:=https://containerd.io/
  DEPENDS:=$(GO_ARCH_DEPENDS) +btrfs-progs +runc
  MENU:=1
endef

define Package/containerd/description
An industry-standard container runtime with an emphasis on simplicity, robustness and portability
endef

GO_PKG_INSTALL_ALL:=1
MAKE_PATH:=$(GO_PKG_WORK_DIR_NAME)/build/src/$(GO_PKG)
MAKE_VARS += $(GO_PKG_VARS)
MAKE_FLAGS += \
	VERSION=$(PKG_VERSION) \
	REVISION=$(PKG_SOURCE_VERSION)

ifeq ($(CONFIG_SELINUX),y)
MAKE_FLAGS += BUILDTAGS='selinux'
else
MAKE_FLAGS += BUILDTAGS=''
endif

# Reset golang-package.mk overrides so we can use the Makefile
Build/Compile=$(call Build/Compile/Default)

define Package/containerd/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/{ctr,containerd,containerd-stress,containerd-shim,containerd-shim-runc-v1,containerd-shim-runc-v2} $(1)/usr/bin/
endef

$(eval $(call BuildPackage,containerd))
