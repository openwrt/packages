include $(TOPDIR)/rules.mk

PKG_NAME:=bully
PKG_VERSION:=1.1
PKG_RELEASE:=31
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/aanarchyy/bully/archive/$(PKV_VERSION).tar.gz
PKG_HASH:=aa379d7e73cdf2dc722d05aa8301754207e5a29bb11bab588c393194df17de48
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE.md
PKG_MAINTAINER:=p4u <p4u@dabax.net>

include $(INCLUDE_DIR)/package.mk

define Package/bully
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=wireless
  TITLE:=Brute force attack against WPS, that actually works
  DEPENDS:=+libpcap +pixiewps
endef

define Package/bully/description
  Brute force attack against WPS, that actually works
endef

CONFIGURE_PATH:=src
MAKE_PATH:=src
TARGET_CFLAGS+=$(TARGET_CPPFLAGS)

define Package/bully/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/bully $(1)/usr/bin/
endef

$(eval $(call BuildPackage,bully)) 
