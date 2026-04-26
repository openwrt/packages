include $(TOPDIR)/rules.mk

PKG_NAME:=runc
PKG_VERSION:=1.3.5
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:linuxfoundation:runc

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/opencontainers/runc/tar.gz/v${PKG_VERSION}?
PKG_HASH:=72620f9b0e62d8da80c0c08a6265ab10d24330c544115c30713ba1429bde706d

PKG_MAINTAINER:=Gerard Ryan <G.M0N3Y.2503@gmail.com>

PKG_BUILD_DEPENDS:=golang/host dockerd
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

GO_PKG:=github.com/opencontainers/runc

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

EMPTY:=
SPACE:= $(EMPTY) $(EMPTY)
ARCH_DEPENDS:=@($(subst $(SPACE),||,$(strip $(filter-out mips mips64 mipsel mips64el,$(subst ||,$(SPACE),$(patsubst @(%),%,$(GO_ARCH_DEPENDS)))))))

define Package/runc
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=runc container runtime
  URL:=https://www.opencontainers.org/
  DEPENDS:=$(ARCH_DEPENDS) +KERNEL_SECCOMP_FILTER:libseccomp
endef

define Package/runc/description
  runc is a CLI tool for spawning and running containers according to the OCI
  specification.
endef

GO_PKG_INSTALL_ALL:=1
MAKE_PATH:=$(GO_PKG_WORK_DIR_NAME)/build/src/$(GO_PKG)
MAKE_VARS += $(GO_PKG_VARS)
MAKE_FLAGS += COMMIT=$(PKG_SOURCE_VERSION)

ifeq ($(ARCH),mips)
MAKE_FLAGS += EXTRA_FLAGS='-buildmode=default'
endif

BUILDTAGS:=
ifeq ($(CONFIG_KERNEL_SECCOMP_FILTER),y)
BUILDTAGS += seccomp
endif
ifeq ($(CONFIG_SELINUX),y)
BUILDTAGS += selinux
endif
MAKE_FLAGS += BUILDTAGS='$(BUILDTAGS)'

# Reset golang-package.mk overrides so we can use the Makefile
Build/Compile=$(call Build/Compile/Default)

define Package/runc/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/runc $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,runc))
