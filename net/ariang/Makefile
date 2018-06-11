include $(TOPDIR)/rules.mk

PKG_NAME:=ariang
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/mayswind/AriaNg-DailyBuild
PKG_SOURCE_DATE:=2018-05-21
PKG_SOURCE_VERSION:=304500c3f042ac5387e4dd5d6ea159999d249314
PKG_MIRROR_HASH:=f5bb5aad024f0916becc8d36832e5d864cd078553c5a719c715a00ecc72af90e

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
  URL:=https://github.com/mayswind/AriaNg
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

Package/ariang-nginx/install = $(Package/ariang/install)

$(eval $(call BuildPackage,ariang))
$(eval $(call BuildPackage,ariang-nginx))
