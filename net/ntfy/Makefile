include $(TOPDIR)/rules.mk

PKG_NAME:=ntfy
PKG_VERSION:=2.27.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/binwiederhier/ntfy/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=1f46463acc177479860861cca8d7ec7da92244eab7ea42d20a89c17055d6641c

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
# libsqlite3 links the system SQLite instead of the bundled amalgamation.
# sqlite_omit_load_extension is required with it, because libsqlite3 is built
# with --disable-load-extension unless CONFIG_SQLITE3_DYNAMIC_EXTENSIONS is set.
GO_PKG_TAGS:=sqlite_omit_load_extension,osusergo,netgo,libsqlite3

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/ntfy
  SECTION:=net
  CATEGORY:=Network
  TITLE:=ntfy - HTTP-based pub-sub notification service
  URL:=https://github.com/binwiederhier/ntfy
  DEPENDS:=$(GO_ARCH_DEPENDS) +libsqlite3 +ca-bundle
  USERID:=ntfy=8180:ntfy=8180
endef

define Package/ntfy/description
  ntfy is a simple HTTP-based pub-sub notification service.
  With ntfy, you can send notifications to your phone or desktop
  via scripts from any computer.
endef

define Package/ntfy/conffiles
/etc/config/ntfy
/etc/ntfy/server.yml
endef

NPM_ENV:= \
	npm_config_cache=$(PKG_BUILD_DIR)/.npm-cache \
	npm_config_tmp=$(PKG_BUILD_DIR)/.npm-tmp \
	npm_config_audit=false \
	npm_config_fund=false \
	npm_config_update_notifier=false

# The server embeds server/docs; the docs are not packaged, so embed a
# placeholder instead of pulling in the mkdocs toolchain, same as upstream.
define Build/Prepare
	$(call Build/Prepare/Default)
	$(INSTALL_DIR) $(PKG_BUILD_DIR)/server/docs
	touch $(PKG_BUILD_DIR)/server/docs/index.html
endef

# The prebuilt native rollup binary npm resolves for linux-x64 is linked against
# a newer glibc than the SDK container provides, and rollup has no JS fallback.
# vite-plugin-pwa pulls it in through workbox-build when it emits the service
# worker. Swap in the platform-independent WASM build that rollup itself names
# as the substitute; package.json and the lockfile stay untouched, so npm ci
# keeps resolving the pinned dependency set.
define Build/Compile/web
	cd $(PKG_BUILD_DIR)/web && \
		$(NPM_ENV) npm ci && \
		rollup_version=`node -p "require('./node_modules/rollup/package.json').version"` && \
		$(NPM_ENV) npm install --no-save --no-package-lock \
			--ignore-scripts --legacy-peer-deps \
			@rollup/wasm-node@$$$$rollup_version && \
		rm -rf node_modules/rollup && \
		mv node_modules/@rollup/wasm-node node_modules/rollup && \
		$(NPM_ENV) npm run build && \
		mv build/index.html build/app.html && \
		rm -f build/config.js && \
		rm -rf ../server/site && \
		mv build ../server/site
endef

define Build/Compile
	$(call Build/Compile/web)
	$(call GoPackage/Build/Compile)
endef

define Package/ntfy/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ntfy.init $(1)/etc/init.d/ntfy

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/ntfy.config $(1)/etc/config/ntfy

	$(INSTALL_DIR) $(1)/etc/ntfy
	$(INSTALL_CONF) ./files/server.yml $(1)/etc/ntfy/server.yml

	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) ./files/ntfy.upgrade $(1)/lib/upgrade/keep.d/ntfy
endef

$(eval $(call GoBinPackage,ntfy))
$(eval $(call BuildPackage,ntfy))
