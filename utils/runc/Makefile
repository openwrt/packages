include $(TOPDIR)/rules.mk

PKG_NAME:=runc
PKG_VERSION:=1.0.0-rc10
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/opencontainers/runc/tar.gz/v${PKG_VERSION}?
PKG_HASH:=6b44985023347fb9c5a2cc6f761df8c41cc2c84a7a68a6e6acf834dff6653a9a
PKG_SOURCE_VERSION:=dc9208a3303feef5b3839f4323d9beb36df0a9dd

PKG_MAINTAINER:=Gerard Ryan <G.M0N3Y.2503@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/opencontainers/runc

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/runc/config
config RUNC_SECCOMP
	depends on PACKAGE_runc
	bool "Enable support for seccomp in runc"
	default DOCKER_SECCOMP
	select KERNEL_SECCOMP
	select PACKAGE_libseccomp
	help
	  Build runc with support for seccomp filters.
	  Select libseccomp which also pulls-in the needed kernel features.
endef

define Package/runc
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=runc container runtime
  URL:=https://www.opencontainers.org/
  DEPENDS:=$(GO_ARCH_DEPENDS) @(aarch64||arm||x86_64) +RUNC_SECCOMP:libseccomp
  MENU:=1
endef

define Package/runc/description
runc is a CLI tool for spawning and running containers according to the OCI specification.
endef

GO_PKG_INSTALL_ALL:=1
MAKE_PATH:=$(GO_PKG_WORK_DIR_NAME)/build/src/$(GO_PKG)
MAKE_VARS += $(call GoPackage/Environment)
MAKE_FLAGS += \
	COMMIT=$(PKG_SOURCE_VERSION)

ifeq ($(ARCH),mips)
MAKE_FLAGS += EXTRA_FLAGS='-buildmode=default'
endif

ifeq ($(CONFIG_RUNC_SECCOMP),y)
MAKE_FLAGS += BUILDTAGS='seccomp'
else
MAKE_FLAGS += BUILDTAGS=''
endif

define Build/Compile
	$(call Build/Compile/Default)
endef

# Avoid installing binaries
define Build/InstallDev
	$(call Build/Compile/Default,clean)
	rm -f $(STAMP_BUILT)
	$(call GoPackage/Build/InstallDev,$(1))
endef

define Package/runc/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/runc $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,runc))
