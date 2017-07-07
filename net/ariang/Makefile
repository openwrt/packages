include $(TOPDIR)/rules.mk

PKG_NAME:=ariang
PKG_VERSION:=0.2.0
PKG_RELEASE:=1

PKG_SOURCE:=aria-ng-$(PKG_VERSION).zip
PKG_SOURCE_URL:=https://github.com/mayswind/AriaNg/releases/download/$(PKG_VERSION)/
PKG_HASH:=0b81ab23b5559519cde5b66535a5683b0062ae175b8bede7d50bbeecb90b7b26
PKG_UNPACK:=unzip -q $(DL_DIR)/$(PKG_SOURCE) -d $(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

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
		$(1)/www/ariang
endef

$(eval $(call BuildPackage,ariang))
