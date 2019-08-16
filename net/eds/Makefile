#
# Copyright 2019 NXP
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=eds
PKG_VERSION:=lsdk-1903
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/NXP/qoriq-edgescale-eds.git
PKG_SOURCE_VERSION:=7d70a8767941aed135d609300a0594dfdc60e5ea
PKG_MIRROR_HASH:=6add268eee57dd9b1fd8acfcafd529caf921b7c7b3c8a1fd0bd84b3a44d613d2

HOST_GO_PREFIX:=$(STAGING_DIR_HOSTPKG)
HOST_GO_VERSION_ID:=cross
HOST_GO_ROOT:=$(HOST_GO_PREFIX)/lib/go-$(HOST_GO_VERSION_ID)
TARGET_GO_PATH:=$(STAGING_DIR)/usr/share/gocode

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/edgescale
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Edgescale for edge computing
  TITLE:=Edgescale agent
  DEPENDS:=@(arm||aarch64) +bootstrap-enroll \
    +fdisk +e2fsprogs +mount-utils +kmod-loop +badblocks \
    +golang-src \
    +coreutils +coreutils-date \
    +ethtool +ca-certificates
endef

define Package/edgescale/config
	source "$(SOURCE)/Config.in"
endef

define Build/Compile
	export PATH=$(HOST_GO_ROOT)/bin:$(PATH); \
	export GOROOT=$(HOST_GO_ROOT); \
	export GOPATH=$(TARGET_GO_PATH); \
	cd $(PKG_BUILD_DIR)/cert-agent; \
	go get github.com/edgeiot/est-client-go; \
	go get github.com/go-yaml/yaml; \
	env CGO_ENABLED=1 GOOS=linux GOARCH=$(LINUX_KARCH) CC=$(KERNEL_CROSS)gcc \
	    go build -o cert-agent --ldflags="-w -s" --tags "default"; \
	cd $(PKG_BUILD_DIR)/mq-agent; \
	go get github.com/sirupsen/logrus; \
	go get github.com/sigma/systemstat; \
	go get github.com/eclipse/paho.mqtt.golang; \
	go get github.com/shirou/gopsutil/disk; \
	env GOOS=linux GOARCH=$(LINUX_KARCH) CGO_ENABLED=1  CC=$(KERNEL_CROSS)gcc \
	    go build --ldflags="-w -s" --tags "default"
endef

define Package/edgescale/install
	$(INSTALL_DIR) $(1)/usr/local/edgescale/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cert-agent/cert-agent $(1)/usr/local/edgescale/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mq-agent/mq-agent $(1)/usr/local/edgescale/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/startup/env.sh $(1)/usr/local/edgescale/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/startup/startup.sh $(1)/usr/local/edgescale/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/startup/ota-updateSet $(1)/usr/local/edgescale/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/startup/ota-statuscheck $(1)/usr/local/edgescale/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/startup/mmc-check.sh $(1)/usr/local/edgescale/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/startup/factory_reset.sh $(1)/usr/local/edgescale/bin/
	$(INSTALL_DIR) $(1)/usr/local/edgescale/conf
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/etc/edgescale-version $(1)/usr/local/edgescale/conf/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/etc/edgescale $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,edgescale))
