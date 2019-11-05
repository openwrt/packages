include $(TOPDIR)/rules.mk

PKG_NAME:=runc
PKG_VERSION:=1.0.0-rc8+91-3e425f80
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/opencontainers/runc
PKG_MIRROR_HASH:=11dce499b6fbdb159d2ef64b0e9b719ccdf6c59ca1cc7ac0026b1d58547fc187
PKG_SOURCE_VERSION:=3e425f80a8c931f88e6d94a8c831b9d5aa481657
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2019-10-15

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
  DEPENDS:=$(GO_ARCH_DEPENDS) @TARGET_x86_64 +RUNC_SECCOMP:libseccomp
  MENU:=1
endef

define Package/runc/description
runc is a CLI tool for spawning and running containers according to the OCI specification.
endef

GO_PKG_INSTALL_ALL:=1
MAKE_PATH:=$(GO_PKG_WORK_DIR_NAME)/build/src/$(GO_PKG)
MAKE_VARS += \
	GOPATH=$(GO_PKG_BUILD_DIR) \
	GOCACHE=$(GO_PKG_CACHE_DIR) \
	GOTMPDIR=$(GO_PKG_TMP_DIR) \
	GOROOT_FINAL=$(GO_TARGET_ROOT) \
	CC=$(TARGET_CC) \
	CXX=$(TARGET_CXX) \
	$(call GoPackage/Environment)
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
	$(call GoPackage/Build/InstallDev,$(1))
endef

define Package/runc/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/runc $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,runc))
