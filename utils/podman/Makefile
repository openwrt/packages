include $(TOPDIR)/rules.mk

PKG_NAME:=podman
PKG_VERSION:=4.3.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/containers/podman/archive/v$(PKG_VERSION)
PKG_HASH:=455c29c4ee78cd6365e5d46e20dd31a5ce4e6e1752db6774253d76bd3ca78813

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>

PKG_BUILD_DEPENDS:=golang/host protobuf/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
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
  DEPENDS:=$(GO_ARCH_DEPENDS) +conmon +cni +cni-plugins +btrfs-progs +glib2 +gnupg2 +uci-firewall +libgpg-error +libseccomp +libgpgme +nsenter +zoneinfo-simple +kmod-veth +PODMAN_SELINUX_SUPPORT:libselinux
endef

define Package/podman/description
  Podman: A tool for managing OCI containers and pods
endef

define Package/podman/config
  menu "Configuration"

    config PODMAN_SELINUX_SUPPORT
    bool "Enable SELinux support"
    default n

    config PODMAN_IPTABLES_FW
    bool "Add iptabels firewall options to default podman network"
    default n

  endmenu
endef

define Package/podman/conffiles
/etc/containers/policy.json
/etc/containers/storage.conf
/etc/containers/registries.conf
/etc/containers/containers.conf
/etc/cni/net.d/87-podman-bridge.conflist
endef

ifdef CONFIG_PODMAN_SELINUX_SUPPORT
  GO_PKG_TAGS=seccomp,exclude_graphdriver_devicemapper,selinux,apparmor
else
  GO_PKG_TAGS=seccomp,exclude_graphdriver_devicemapper,apparmor
endif

ifdef CONFIG_PODMAN_IPTABLES_FW
  CNIFILE:=87-podman-bridge-iptables.conflist
else
  CNIFILE:=87-podman-bridge.conflist
endif

MAKE_VARS += \
	GO_INSTALL_BIN_PATH="$(strip $(GO_PKG_INSTALL_BIN_PATH))" \
	BUILD_DIR="$(PKG_BUILD_DIR)" \
	GO_BUILD_DIR="$(GO_PKG_BUILD_DIR)" \
	GO_BUILD_BIN_DIR="$(GO_PKG_BUILD_BIN_DIR)" \
	GO_BUILD_DEPENDS_PATH="$(GO_PKG_BUILD_DEPENDS_PATH)" \
	GO_BUILD_DEPENDS_SRC="$(GO_PKG_BUILD_DEPENDS_SRC)" \
	GOOS="$(GO_OS)" \
	GOARCH="$(GO_ARCH)" \
	CC="$(TARGET_CC)" \
	CXX="$(TARGET_CXX)" \
	CGO_CFLAGS="$(filter-out $(GO_CFLAGS_TO_REMOVE),$(TARGET_CFLAGS))" \
	CGO_CPPFLAGS="$(TARGET_CPPFLAGS)" \
	CGO_CXXFLAGS="$(filter-out $(GO_CFLAGS_TO_REMOVE),$(TARGET_CXXFLAGS))" \
	CGO_LDFLAGS="$(TARGET_LDFLAGS)" \
	GOPATH="$(GO_PKG_BUILD_DIR)" \
	GOCACHE="$(GO_BUILD_CACHE_DIR)" \
	GOMODCACHE="$(GO_MOD_CACHE_DIR)" \
	GOFLAGS="$(GO_PKG_GCFLAGS)" \
	GO_PKG_CFLAGS="$(GO_PKG_CFLAGS)" \
	CGO_ENABLED=1 \
	GOENV=off \
	PREFIX=/usr \
	LIBEXECDIR=/usr/lib \
	LIBEXECPODMAN=/usr/lib/podman \
	SHAREDIR_CONTAINERS=/usr/share/containers \
	ETCDIR=/etc \
	TMPFILESDIR=/var/run/podman \
	BUILDTAGS="$(GO_PKG_TAGS)" \
	EXTRA_LDFLAGS="$(GO_PKG_LDFLAGS)"

define Build/Prepare
	$(call Build/Prepare/Default)
	$(eval $(call Download,default-registries))
	$(eval $(call Download,default-policy))
endef

define Package/podman/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/podman
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/{podman,podman-remote} $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/podman/rootlessport $(1)/usr/lib/podman/
	$(INSTALL_DIR) $(1)/etc/containers
	$(INSTALL_DATA) $(DL_DIR)/default-policy.json-362f70b056 $(1)/etc/containers/policy.json
	$(INSTALL_DATA) $(DL_DIR)/registries.fedora-da9a9c8778 $(1)/etc/containers/registries.conf
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/vendor/github.com/containers/storage/storage.conf $(1)/etc/containers/storage.conf
	$(INSTALL_DATA) ./files/containers.conf $(1)/etc/containers/containers.conf
	$(INSTALL_DIR) $(1)/etc/cni/net.d
	$(INSTALL_CONF) ./files/$(CNIFILE) $(1)/etc/cni/net.d/87-podman-bridge.conflist
	$(INSTALL_DIR) $(1)/usr/share/containers
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/vendor/github.com/containers/common/pkg/seccomp/seccomp.json $(1)/usr/share/containers/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/podman.init $(1)/etc/init.d/podman
	$(SED) 's/driver = \"\"/driver = \"overlay\"/g' $(1)/etc/containers/storage.conf
endef

$(eval $(call BuildPackage,podman))
