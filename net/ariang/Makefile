include $(TOPDIR)/rules.mk

PKG_NAME:=ariang
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/mayswind/AriaNg-DailyBuild.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=92c9caf902d509363aa4cb59316f9f687eb16068
PKG_MIRROR_HASH:=ea2773bc9fe839c64d794de6d57fe7fbd7f7b44591bcbde14fa86620f5d3cb27

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Ansuel Smith <ansuelsmth@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/ariang
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Download Manager
  DEPENDS:=
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
		$(PKG_BUILD_DIR)/robots.txt \
		$(PKG_BUILD_DIR)/LICENSE \
		$(PKG_BUILD_DIR)/favicon.* \
		$(1)/www/ariang
endef

$(eval $(call BuildPackage,ariang))
