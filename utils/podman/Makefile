include $(TOPDIR)/rules.mk

PKG_NAME:=podman
PKG_VERSION:=6.1.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/podman-container-tools/podman/archive/v$(PKG_VERSION)
PKG_HASH:=a4b2b10bd560cf9b4c50c282bd04bb74486ff6c78bebd51427f779fe985fc1bb

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_CPE_ID:=cpe:/a:podman_project:podman

PKG_BUILD_DEPENDS:=golang/host protobuf/host btrfs-progs
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Download/default-policy
  URL:=https://raw.githubusercontent.com/containers/skopeo/362f70b056a1f5d2bd4184527a0ae0d20c4d35d3
  URL_FILE:=default-policy.json
  FILE:=default-policy.json-362f70b056
  HASH:=cddfaa8e6a7e5497b67cc0dd8e8517058d0c97de91bf46fff867528415f2d946
endef

define Package/podman
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Podman
  URL:=https://podman.io
  DEPENDS:=$(GO_ARCH_DEPENDS) +conmon +libgpgme +libseccomp +nsenter \
	+zoneinfo-simple +kmod-veth +passt +netavark +aardvark-dns \
	+catatonit +crun +PODMAN_SELINUX_SUPPORT:libselinux
endef

define Package/podman/description
  Podman: A tool for managing OCI containers and pods
endef

define Package/podman/config
  menu "Configuration"

    config PODMAN_SELINUX_SUPPORT
    bool "Enable SELinux support"
    default n

  endmenu
endef

define Package/podman/conffiles
/etc/containers/policy.json
/etc/containers/storage.conf
/etc/containers/registries.conf
/etc/containers/containers.conf
/etc/containers/networks/podman.json
endef

GO_PKG_TAGS:=seccomp exclude_graphdriver_devicemapper apparmor
ifdef CONFIG_PODMAN_SELINUX_SUPPORT
  GO_PKG_TAGS+= selinux
endif

MAKE_VARS += \
	$(GO_GENERAL_BUILD_CONFIG_VARS) \
	$(GO_PKG_BUILD_CONFIG_VARS) \
	$(GO_PKG_VARS) \
	GIT_COMMIT="" \
	DESTDIR="$(PKG_INSTALL_DIR)" \
	PREFIX=/usr \
	LIBEXECDIR=/usr/lib \
	LIBEXECPODMAN=/usr/lib/podman \
	TMPFILESDIR=/var/run/podman \
	BUILDTAGS="$(GO_PKG_TAGS)"

define Build/Prepare
	$(call Build/Prepare/Default)
	$(eval $(call Download,default-policy))
endef

define Build/Compile
	$(call Build/Compile/Default,binaries)
endef

define Build/Install
	$(call Build/Compile/Default,install.bin)
endef

ifneq ($(CONFIG_USE_MUSL),)
  TARGET_CFLAGS += -D_LARGEFILE64_SOURCE
endif

define Package/podman/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/podman
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/podman $(1)/usr/bin/
	$(INSTALL_BIN) ./files/podman-remote.sh $(1)/usr/bin/podman-remote
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/podman/{rootlessport,quadlet} $(1)/usr/lib/podman/
	$(LN) podman $(1)/usr/bin/podmansh
	$(INSTALL_DIR) $(1)/etc/containers
	$(INSTALL_DATA) $(DL_DIR)/default-policy.json-362f70b056 $(1)/etc/containers/policy.json
	$(INSTALL_DATA) ./files/default-registries.conf $(1)/etc/containers/registries.conf
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/vendor/go.podman.io/storage/storage.conf $(1)/etc/containers/storage.conf
	$(INSTALL_DATA) ./files/containers.conf $(1)/etc/containers/containers.conf
	$(INSTALL_DIR) $(1)/etc/containers/networks
	$(INSTALL_CONF) ./files/podman.json $(1)/etc/containers/networks
	$(INSTALL_DIR) $(1)/usr/share/containers
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/vendor/go.podman.io/common/pkg/seccomp/seccomp.json $(1)/usr/share/containers/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/podman.init $(1)/etc/init.d/podman
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/podman.defaults $(1)/etc/uci-defaults/90-podman
	$(SED) 's/driver = \"\"/driver = \"overlay\"/g' $(1)/etc/containers/storage.conf
endef

$(eval $(call BuildPackage,podman))
