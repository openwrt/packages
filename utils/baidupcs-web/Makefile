include $(TOPDIR)/rules.mk

PKG_NAME:=baidupcs-web
PKG_VERSION:=3.7.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/liuzhuoling2011/BaiduPCS-Go.git
PKG_SOURCE_VERSION:=cbc3e9e932d5c7a2b2302e4cd1b102f6f56fec44

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE.txt

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/liuzhuoling2011/BaiduPCS-Go
GO_PKG_LDFLAGS:=-w -s
GO_PKG_LDFLAGS_X:=main.Version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/baidupcs-web
	SECTION:=net
	CATEGORY:=Network
	TITLE:=BaiduPCS-Web is a web controller for BaiduPCS-Go
	URL:=https://github.com/liuzhuoling2011/BaiduPCS-Go.git
	DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/baidupcs-web/description
BaiduPCS-Web is a web controller for BaiduPCS-Go
endef

USER_PATH:=`cd && pwd`

define Build/Compile
	( \
		$(call GoPackage/Build/Compile) ; \
		rm -rf $(GO_PKG_BUILD_BIN_DIR)/AndroidNDKBuild ; \
		pushd $(PKG_BUILD_DIR) ; \
		go get -u -v github.com/GeertJohan/go.rice ; \
		go get -u -v github.com/GeertJohan/go.rice/rice ; \
		$(USER_PATH)/go/bin/rice -i ./internal/pcsweb append --exec $(GO_PKG_BUILD_BIN_DIR)/* ; \
		popd ; \
	)
endef

define Package/baidupcs-web/install
	$(call GoPackage/Package/Install/Bin,$(1))
endef

$(eval $(call GoBinPackage,baidupcs-web))
$(eval $(call BuildPackage,baidupcs-web))
