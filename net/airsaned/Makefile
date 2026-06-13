include $(TOPDIR)/rules.mk

PKG_NAME:=airsaned
PKG_VERSION:=0.4.12
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/SimulPiscator/AirSane/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=2697bdbfb709972834d782a53d1ef52c9f7714a06d286ae6b4c8d06f04da6106

PKG_MAINTAINER:=SimulPiscator <https://github.com/SimulPiscator>
PKG_LICENSE:=GPL-3.0

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

TAR_OPTIONS:=--strip-components 1 $(TAR_OPTIONS)
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)

define Package/airsaned
  TITLE:=Publish SANE scanners to MacOS, Android, and Windows via Apple AirScan
  URL:=https://github.com/SimulPiscator/AirSane
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libsane +libjpeg +libpng +libavahi-client +libusb-1.0 +libstdcpp +libatomic
endef

define Package/airsaned/description
  Publish SANE scanners to MacOS, Android, and Windows via Apple AirScan.
  AirSane is a SANE frontend, and a scanner server that supports Apple's AirScan protocol. Scanners are detected automatically, and published through mDNS. Acquired images may be transferred in JPEG, PNG, and PDF/raster format.
endef

define Package/airsaned/conffiles
	/etc/config/airsaned
endef

define Package/airsaned/install 
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/airsaned $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) files/airsaned.init $(1)/etc/init.d/airsaned
	$(INSTALL_DIR) $(1)/etc/config/
	$(CP) files/airsaned.default $(1)/etc/config/airsaned
endef

$(eval $(call BuildPackage,airsaned))
