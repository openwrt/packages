include $(TOPDIR)/rules.mk

PKG_NAME:=dtoverlay
PKG_VERSION:=2016-07-06
PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git://github.com/ya-mouse/dtoverlay.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=d503ddae11d62f12762b2fd3a52d37da55645d4b
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

CMAKE_INSTALL:=1

PKG_LICENSE:=PublicDomain

PKG_MAINTAINER:=Anton D. Kachalov <mouse@yandex-team.ru>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/dtoverlay
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=DeviceTree manipulation tools
  URL:=https://github.com/raspberrypi/userland/tree/master/host_applications/linux/apps/dtoverlay
endef

define Package/dtoverlay/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dtoverlay $(1)/usr/bin/dtoverlay
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dtmerge $(1)/usr/bin/dtmerge
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dtc $(1)/usr/bin/dtc
	$(LN) dtoverlay $(1)/usr/bin/dtparam
endef

$(eval $(call BuildPackage,dtoverlay))
