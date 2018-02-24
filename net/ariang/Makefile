include $(TOPDIR)/rules.mk

PKG_NAME:=ariang
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/mayswind/AriaNg-DailyBuild
PKG_SOURCE_DATE:=2018-02-21
PKG_SOURCE_VERSION:=f71a67cbb034aebcd076db3fadc1b9d8cdc470c7
PKG_MIRROR_HASH:=13b07acbe29a68929295a82deb5a0122d8a56e328f783b6bc1efe9c72b99a702

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Ansuel Smith <ansuelsmth@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/ariang
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Download Manager
  DEPENDS:=+uhttpd +aria2
  TITLE:=AriaNg is a web frontend making aria2 easier to use.
  URL:=https://github.com/mayswind/AriaNg
  PKGARCH:=all
endef

define Package/ariang/description
	AriaNg is a web frontend making aria2 easier to use. AriaNg is written in pure html & javascript, thus it does not need any compilers or runtime environment.
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

$(eval $(call BuildPackage,ariang))
