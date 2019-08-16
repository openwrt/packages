#
# Copyright 2019 NXP
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=eds-kubelet
PKG_VERSION:=lsdk-1903
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/NXP/qoriq-eds-kubelet.git
PKG_SOURCE_VERSION:=cf5175b3186e1308cc29a6295fb7bd012b614a22
PKG_MIRROR_HASH:=5cd302bc73a1ab21245bdcd2009e5c39c0e244f62c78904fd940fca6ea0a8ca2

HOST_GO_PREFIX:=$(STAGING_DIR_HOSTPKG)
HOST_GO_VERSION_ID:=cross
HOST_GO_ROOT:=$(HOST_GO_PREFIX)/lib/go-$(HOST_GO_VERSION_ID)
TARGET_GO_PATH:=$(STAGING_DIR)/usr/share/gocode

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/edgescale-kubelet
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Edgescale for edge computing
  TITLE:=Edgescale Kubelet
  DEPENDS:=@(arm||aarch64) +edgescale \
    +kmod-veth +kmod-br-netfilter +kmod-nf-ipvs +kmod-nf-nat +kmod-ipt-extra \
    +iptables +iptables-mod-extra +haveged +resize2fs
endef

define Package/edgescale-kubelet/config
	source "$(SOURCE)/Config.in"
endef

define Build/Compile
	cd $(BUILD_DIR); \
	export PATH=$(HOST_GO_ROOT)/bin:$(PATH); \
	export GOROOT=$(HOST_GO_ROOT); \
	export GOPATH=$(TARGET_GO_PATH); \
	if [ ! -d $(TARGET_GO_PATH)/src/k8s.io ]; then \
		mkdir -p $(TARGET_GO_PATH)/src/k8s.io; \
	fi; \
	mkdir -p $(TARGET_GO_PATH)/images; \
	if [ ! -f $(TARGET_GO_PATH)/src/k8s.io/kubernetes/pkg/version/version.go ]; then  \
		wget -c https://github.com/kubernetes/kubernetes/archive/v1.7.0.tar.gz; \
		tar -xf v1.7.0.tar.gz; \
		mv kubernetes-1.7.0 $(TARGET_GO_PATH)/src/k8s.io/kubernetes; \
		rm v1.7.0.tar.gz; \
	fi; \
	export CGO_ENABLED=1 GOOS=linux GOARCH=$(LINUX_KARCH); \
	export CC=$(KERNEL_CROSS)gcc; \
	cd $(TARGET_GO_PATH)/src/k8s.io/kubernetes; \
	go env; \
	go build -o $(TARGET_GO_PATH)/images/kubelet --ldflags="-w -s" cmd/kubelet/kubelet.go
endef

define Package/edgescale-kubelet/install
	$(INSTALL_DIR) $(1)/usr/local/edgescale/bin
	$(INSTALL_BIN) $(TARGET_GO_PATH)/images/kubelet $(1)/usr/local/edgescale/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/* $(1)/usr/local/edgescale/bin/
	sed -i s/pause-arm64/pause-$(LINUX_KARCH)/g $(1)/usr/local/edgescale/bin/k8s.sh
endef

$(eval $(call BuildPackage,edgescale-kubelet))
