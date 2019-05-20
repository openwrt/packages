include $(TOPDIR)/rules.mk

PKG_NAME:=fadecandyserver
PKG_VERSION:=2.1.05
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://codeload.github.com/bluewavenet/fadecandyserver/tar.gz/v$(PKG_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_HASH:= #shasum -a 256 of tar.gz of source files goes here
PKG_HASH:= 4033711b2b21ade83013828b383ac386716b9f724e6607cb2ef4cb4b76787c71
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Rob White <rob@blue-wave.net>
PKG_BUILD_PARALLEL:=1
PKG_LICENSE:=MIT


include $(INCLUDE_DIR)/package.mk

define Package/fadecandyserver
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=FadeCandy Server
  URL:=https://github.com/bluewavenet/fadecandyserver
  DEPENDS:=+libpthread +librt +libstdcpp
endef

define Package/fadecandyserver/description
  FadeCandy Server For OpenWrt.
  The Fadecandy Server is a background process that handles
  USB communications with Fadecandy LED Controller boards.
  Pixel data can be sent to a Controller board using
  Open Pixel Control protocol over the network
  or from a web app via WebSockets.

  * Support multiple Fadecandy boards
  * Mix Fadecandy and DMX lighting devices
  * Listen on a configurable TCP port
  * Listen for connections from the network, not just from local programs

  This package contains the fadecandyserver utility.
  It was derived originally from the codebase of the FadeCandy project.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/ \
		CXX=$(TARGET_CC) \
		CC="$(TARGET_CC) -fhonour-copts" \
		STRIP_CMD="$(TARGET_STRIP) $(TARGET)"
endef

define Package/fadecandyserver/install
	$(INSTALL_DIR) $(1)/usr
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/fcserver $(1)/usr/bin/
	$(CP) $(PKG_BUILD_DIR)/openwrt/etc/initd/fadecandyserver $(1)/etc/init.d/
	$(CP) $(PKG_BUILD_DIR)/openwrt/etc/config/fadecandyserver $(1)/etc/config/
endef

$(eval $(call BuildPackage,fadecandyserver))
