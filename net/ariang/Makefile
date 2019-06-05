include $(TOPDIR)/rules.mk

PKG_NAME:=ariang
PKG_VERSION:=1.1.1
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://codeload.github.com/mayswind/AriaNg-DailyBuild/tar.gz/$(PKG_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=48f3f737a6a79ab140f6bc75b0b6fd377ccbb75c7b7260b38ad4e64dee97d9e8
PKG_BUILD_DIR:=$(BUILD_DIR)/AriaNg-DailyBuild-$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Ansuel Smith <ansuelsmth@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/ariang/default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Download Manager
  DEPENDS:=+aria2
  TITLE:=AriaNg webui
  URL:=https://ariang.mayswind.net
  PKGARCH:=all
endef

define Package/ariang/description
	AriaNg is a web frontend making aria2 easier to use. AriaNg is written in pure html & javascript, thus it does not need any compilers or runtime environment.
endef

Package/ariang-nginx/description = $(Package/ariang/description)

define Package/ariang
  $(Package/ariang/default)
  DEPENDS += +uhttpd
  TITLE += for uhttpd webserver
endef

define Package/ariang-nginx
  $(Package/ariang/default)
  DEPENDS += +nginx
  TITLE += for nginx webserver
endef

define Build/Compile
endef

define Package/ariang/install
	$(INSTALL_DIR) \
		$(1)/www/ariang

	$(CP) \
		$(PKG_BUILD_DIR)/{langs,css,js,fonts} \
		$(PKG_BUILD_DIR)/index.html \
		$(PKG_BUILD_DIR)/index.manifest \
		$(PKG_BUILD_DIR)/LICENSE \
		$(PKG_BUILD_DIR)/favicon.ico \
		$(1)/www/ariang
endef

define Package/ariang-nginx/install
	$(Package/ariang/install)
	$(INSTALL_DIR) $(1)/etc/nginx
	$(INSTALL_BIN) ./files/ariang.conf $(1)/etc/nginx/ariang.conf
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/80_ariang-nginx-support $(1)/etc/uci-defaults/80_ariang-nginx-support
endef

$(eval $(call BuildPackage,ariang))
$(eval $(call BuildPackage,ariang-nginx))
