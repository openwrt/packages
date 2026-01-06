include $(TOPDIR)/rules.mk

PKG_NAME:=podman
PKG_VERSION:=5.2.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/containers/podman/archive/v$(PKG_VERSION)
PKG_HASH:=571658f175d61724269c1a20626c1e39424af59b7bcf7ff94135d03b790bbecb

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>

PKG_BUILD_DEPENDS:=golang/host protobuf/host btrfs-progs
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Download/default-registries
  URL:=https://raw.githubusercontent.com/projectatomic/registries/da9a9c87781823f45401ca49da04e269c9e3100e
  URL_FILE:=registries.fedora
  FILE:=registries.fedora-da9a9c8778
  HASH:=bc2b58c209aa8ca35b6814ec9a3c64716d4970b884ade460b65000e56024dfee
endef

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
	+zoneinfo-simple +kmod-veth +slirp4netns +netavark +aardvark-dns \
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
	PREFIX=/usr \
	LIBEXECDIR=/usr/lib \
	LIBEXECPODMAN=/usr/lib/podman \
	TMPFILESDIR=/var/run/podman \
	BUILDTAGS="$(GO_PKG_TAGS)"

define Build/Prepare
	$(call Build/Prepare/Default)
	$(eval $(call Download,default-registries))
	$(eval $(call Download,default-policy))
endef

ifneq ($(CONFIG_USE_MUSL),)
  TARGET_CFLAGS += -D_LARGEFILE64_SOURCE
endif

define Package/podman/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/podman
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/{podman,podman-remote} $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/podman/{rootlessport,quadlet} $(1)/usr/lib/podman/
	$(LN) podman $(1)/usr/bin/podmansh
	$(INSTALL_DIR) $(1)/etc/containers
	$(INSTALL_DATA) $(DL_DIR)/default-policy.json-362f70b056 $(1)/etc/containers/policy.json
	$(INSTALL_DATA) $(DL_DIR)/registries.fedora-da9a9c8778 $(1)/etc/containers/registries.conf
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/vendor/github.com/containers/storage/storage.conf $(1)/etc/containers/storage.conf
	$(INSTALL_DATA) ./files/containers.conf $(1)/etc/containers/containers.conf
	$(INSTALL_DIR) $(1)/etc/containers/networks
	$(INSTALL_CONF) ./files/podman.json $(1)/etc/containers/networks
	$(INSTALL_DIR) $(1)/usr/share/containers
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/vendor/github.com/containers/common/pkg/seccomp/seccomp.json $(1)/usr/share/containers/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/podman.init $(1)/etc/init.d/podman
	$(SED) 's/driver = \"\"/driver = \"overlay\"/g' $(1)/etc/containers/storage.conf
endef

$(eval $(call BuildPackage,podman))
