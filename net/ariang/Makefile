include $(TOPDIR)/rules.mk

PKG_NAME:=ariang
PKG_VERSION:=1.3.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).zip
PKG_SOURCE_URL:=https://github.com/mayswind/AriaNg/releases/download/$(PKG_VERSION)
PKG_HASH:=2d36e1a39d95867b8e0cdb3cde96d04d40117bd37e8742d639da92496e07cc7b
UNPACK_CMD=unzip -q -d $(1) $(DL_DIR)/$(PKG_SOURCE)

PKG_MAINTAINER:=Ansuel Smith <ansuelsmth@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

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
		$(PKG_BUILD_DIR)/LICENSE \
		$(PKG_BUILD_DIR)/favicon.* \
		$(PKG_BUILD_DIR)/robots.txt \
		$(PKG_BUILD_DIR)/tileicon.png \
		$(PKG_BUILD_DIR)/touchicon.png \
		$(1)/www/ariang
endef

define Package/ariang-nginx/install
	$(Package/ariang/install)
	$(INSTALL_DIR) $(1)/etc/nginx/conf.d/
	$(INSTALL_BIN) ./files/ariang.locations $(1)/etc/nginx/conf.d/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/80_ariang-nginx-support $(1)/etc/uci-defaults/80_ariang-nginx-support
endef

$(eval $(call BuildPackage,ariang))
$(eval $(call BuildPackage,ariang-nginx))
