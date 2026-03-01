include $(TOPDIR)/rules.mk

PKG_NAME:=frp
PKG_VERSION:=0.67.0
PKG_RELEASE:=1

PKG_MAINTAINER:=
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

USE_PREBUILT:=0
ARCH_ID:=$(strip $(if $(ARCH_PACKAGES),$(ARCH_PACKAGES),$(ARCH)))

ifneq (,$(filter x86_64,$(ARCH_ID)))
  USE_PREBUILT:=1
  PKG_ARCH:=amd64
  PKG_HASH:=f8629ca7ca56b8e7e7a9903779b8d5c47c56ad1b75b99b2d7138477acc4c7105
else ifneq (,$(filter aarch64%,$(ARCH_ID)))
  USE_PREBUILT:=1
  PKG_ARCH:=arm64
  PKG_HASH:=0e9683226acdcbbb2ac8d073f35ba8be2a8b1e7584684d2073f39d337ebd6de7
else ifneq (,$(filter arm%,$(ARCH_ID)))
  USE_PREBUILT:=1
  PKG_ARCH:=arm
  PKG_HASH:=d6b3cef9a7ebb2d954dc402626a9061933eec2be9d461c820a7c15ae74f7e59a
else ifneq (,$(filter mipsel%,$(ARCH_ID)))
  USE_PREBUILT:=1
  PKG_ARCH:=mipsle
  PKG_HASH:=fe825a71ccdf247edc71e5b034d2b784790d72c2977a08cf021936d6d3bcbd3d
else ifneq (,$(filter mips64el%,$(ARCH_ID)))
  USE_PREBUILT:=1
  PKG_ARCH:=mips64le
  PKG_HASH:=a259d498d890fabd7d1da70efde47f4e6293cecf5a429c55d3f26c3566519dad
else ifneq (,$(filter mips64%,$(ARCH_ID)))
  USE_PREBUILT:=1
  PKG_ARCH:=mips64
  PKG_HASH:=7051bc691c655ff287840c82015d5efa29c4a3afbaceead9c2d0e1d2e8f7695a
else ifneq (,$(filter mips%,$(ARCH_ID)))
  USE_PREBUILT:=1
  PKG_ARCH:=mips
  PKG_HASH:=62f0a672897975f20ace4788dd411360ce65962a0c2169ff241a40d2fd793f3b
else ifneq (,$(filter loongarch64%,$(ARCH_ID)))
  USE_PREBUILT:=1
  PKG_ARCH:=loong64
  PKG_HASH:=ee26af771409050098d9759e73675ba40fb96bc30e14a225cb3f79197f73cd54
else ifneq (,$(filter riscv64%,$(ARCH_ID)))
  USE_PREBUILT:=1
  PKG_ARCH:=riscv64
  PKG_HASH:=c22b9280bbdd7976af25f43f58fd7a674f5f44738b1004bb83c7f41199f3c836
endif

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

ifeq ($(USE_PREBUILT),1)
  PKG_SOURCE:=frp_$(PKG_VERSION)_linux_$(PKG_ARCH).tar.gz
  PKG_SOURCE_URL:=https://github.com/fatedier/frp/releases/download/v$(PKG_VERSION)/
else
  PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
  PKG_SOURCE_URL:=https://codeload.github.com/fatedier/frp/tar.gz/v$(PKG_VERSION)?
  PKG_HASH:=18d0a35b965fab7e348aafc7b587847dd04ef2ef84822ed8fd5b9fe46b7ff6d7

  PKG_BUILD_DEPENDS:=golang/host
  PKG_BUILD_PARALLEL:=1
  PKG_BUILD_FLAGS:=no-mips16

  GO_PKG:=github.com/fatedier/frp
  GO_PKG_BUILD_PKG:=github.com/fatedier/frp/cmd/frpc github.com/fatedier/frp/cmd/frps
  GO_PKG_LDFLAGS:=-s -w
  GO_PKG_LDFLAGS_X:=github.com/fatedier/frp/pkg/util/version.version=$(PKG_VERSION)
endif

include $(INCLUDE_DIR)/package.mk

ifneq ($(USE_PREBUILT),1)
  include ../../lang/golang/golang-package.mk
endif

ifeq ($(USE_PREBUILT),1)

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	tar -xzf $(DL_DIR)/$(PKG_SOURCE) -C $(PKG_BUILD_DIR) --strip-components=1
endef

define Build/Compile
	true
endef

else

define Build/Prepare
	$(call Build/Prepare/Default)
	mkdir -p $(PKG_BUILD_DIR)/web/frpc/dist
	mkdir -p $(PKG_BUILD_DIR)/web/frps/dist
	echo 'WebUI is not available in this build.' > $(PKG_BUILD_DIR)/web/frpc/dist/index.html
	echo 'WebUI is not available in this build.' > $(PKG_BUILD_DIR)/web/frps/dist/index.html
endef

endif

define Package/frp/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_DIR) $(1)/etc/init.d/

	$(INSTALL_CONF) ./files/$(2).config $(1)/etc/config/$(2)
	$(INSTALL_BIN)  ./files/$(2).init   $(1)/etc/init.d/$(2)

	if [ -r ./files/$(2).uci-defaults ]; then \
		$(INSTALL_DIR) $(1)/etc/uci-defaults; \
		$(INSTALL_DATA) ./files/$(2).uci-defaults $(1)/etc/uci-defaults/$(2); \
	fi

	if [ "$(USE_PREBUILT)" = "1" ]; then \
		$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(2) $(1)/usr/bin/; \
	else \
		$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/$(2) $(1)/usr/bin/; \
	fi
endef

define Package/frp/template
  define Package/$(1)
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    TITLE:=$(1) - fast reverse proxy $(2)
    URL:=https://github.com/fatedier/frp
    DEPENDS:=$(if $(filter 1,$(USE_PREBUILT)),,$(GO_ARCH_DEPENDS))
  endef

  define Package/$(1)/description
    $(1) is a fast reverse proxy $(2) that helps you expose a local server
    behind a NAT or firewall to the internet.

    This package uses precompiled binaries from official frp releases when
    available. On architectures without official binaries it is built from
    source without the full WebUI (static files), while the core proxy
    functionality remains fully available.
  endef

  define Package/$(1)/conffiles
/etc/config/$(1)
  endef

  define Package/$(1)/install
    $(call Package/frp/install,$$(1),$(1))
  endef
endef

$(eval $(call Package/frp/template,frpc,client))
$(eval $(call Package/frp/template,frps,server))
$(eval $(call BuildPackage,frpc))
$(eval $(call BuildPackage,frps))
