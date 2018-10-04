include $(TOPDIR)/rules.mk

PKG_NAME:=libjpeg-turbo
PKG_VERSION:=2.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/$(PKG_NAME)
PKG_HASH:=778876105d0d316203c928fd2a0374c8c01f755d0a00b12a1c8934aeccff8868

PKG_MAINTAINER:=Rosen Penev <rosenp@gmail.com>
PKG_LICENSE:=BSD-3-Clause IJG zlib
PKG_LICENSE_FILES:=LICENSE.md

PKG_USE_MIPS16:=0 #Allows ASM compilation for speed.
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libjpeg-turbo
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libjpeg-turbo
  URL:=https://libjpeg-turbo.org/
endef

define Package/libjpeg-turbo-utils
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libjpeg-turbo
  TITLE:=libjpeg-turbo-utils
  URL:=https://libjpeg-turbo.org/
endef

define Package/libjpeg-turbo/description
	libjpeg-turbo is a speed focused fork of libjpeg.
endef

define Package/libjpeg-turbo-utils/description
	These are the JPEG utilities that come with libjpeg-turbo.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libturbojpeg.{a,so*} $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libjpeg.{a,so*} $(1)/usr/lib
endef

define Package/libjpeg-turbo/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libturbojpeg.so* $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libjpeg.so* $(1)/usr/lib
endef

define Package/libjpeg-turbo-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/tjbench $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rdjpgcom $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/wrjpgcom $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/cjpeg $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/djpeg $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/jpegtran $(1)/usr/bin
endef

$(eval $(call BuildPackage,libjpeg-turbo))
$(eval $(call BuildPackage,libjpeg-turbo-utils))
