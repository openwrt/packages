include $(TOPDIR)/rules.mk

PKG_NAME:=liblognorm
PKG_VERSION:=2.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/rsyslog/liblognorm/archive/v$(PKG_VERSION)
PKG_HASH:=1f6c63d218a0a182b7758ce177033b604c2df30bbff80ea42b9bc032975e9ca9

PKG_MAINTAINER:=Carlo Filippi <carlo@common-net.org>
PKG_LICENSE:=LGPL-2.1-or-later Apache-2.0
PKG_LICENSE_FILES:=COPYING COPYING.ASL20

PKG_FIXUP:=autoreconf

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/liblognorm
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Lognorm library
  URL:=https://www.liblognorm.com/
  DEPENDS:=+libestr +libfastjson
endef

define Package/liblognorm/description
  Liblognorm is a fast-samples based log normalization library
endef

CONFIGURE_ARGS += --enable-docs=no
TARGET_CFLAGS += $(FPIC)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
endef

define Package/liblognorm/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liblognorm.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,liblognorm))
