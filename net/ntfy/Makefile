include $(TOPDIR)/rules.mk

PKG_NAME:=ntfy
PKG_VERSION:=2.24.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/binwiederhier/ntfy/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=4b9e47923fe4b99af9f359da3dbbcd3e07dc1e5543fbc08f6cce095b36ce45c1

PKG_MAINTAINER:=Rosa Hase <github@smnx.addy.io>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host node/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=heckel.io/ntfy/v2
GO_PKG_BUILD_PKG:=$(GO_PKG)
GO_PKG_LDFLAGS_X:= \
	main.version=$(PKG_VERSION)
GO_PKG_TAGS:=sqlite_omit_load_extension,osusergo,netgo

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/ntfy
  SECTION:=net
  CATEGORY:=Network
  TITLE:=ntfy - HTTP-based pub-sub notification service
  URL:=https://github.com/binwiederhier/ntfy
  DEPENDS:=$(GO_ARCH_DEPENDS) +libsqlite3
endef

define Package/ntfy/description
  ntfy is a simple HTTP-based pub-sub notification service.
  With ntfy, you can send notifications to your phone or desktop
  via scripts from any computer.
endef

define Package/ntfy/conffiles
/etc/ntfy/server.yml
/etc/ntfy/user.db
endef

define Build/Compile
	mkdir -p $(PKG_BUILD_DIR)/server/docs
	touch $(PKG_BUILD_DIR)/server/docs/index.html
	cd $(PKG_BUILD_DIR)/web; \
	npm_config_cache=$(TMP_DIR)/npm-cache-$(PKG_NAME) npm_config_tmp=$(TMP_DIR)/npm-tmp-$(PKG_NAME) npm ci; \
	npm_config_cache=$(TMP_DIR)/npm-cache-$(PKG_NAME) npm_config_tmp=$(TMP_DIR)/npm-tmp-$(PKG_NAME) npm run build; \
	rm -rf $(TMP_DIR)/npm-tmp-$(PKG_NAME) $(TMP_DIR)/npm-cache-$(PKG_NAME); \
	mv build/index.html build/app.html; \
	mv build ../server/site; \
	rm -f ../server/site/config.js
	$(call GoPackage/Build/Compile)
endef

define Package/ntfy/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ntfy.init $(1)/etc/init.d/ntfy

	$(INSTALL_DIR) $(1)/etc/ntfy
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/server/server.yml $(1)/etc/ntfy/server.yml
endef

$(eval $(call GoBinPackage,ntfy))
$(eval $(call BuildPackage,ntfy))
