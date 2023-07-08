include $(TOPDIR)/rules.mk

PKG_NAME:=easyloggingpp
PKG_VERSION:=9.97.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/abumq/easyloggingpp.git
PKG_SOURCE_VERSION:=v9.97.0
PKG_SOURCE_DATE:=2020-12-25

PKG_MIRROR_HASH:=9acdb77ca418b07feef4ffc4ae1858c0a11f9e44c44a0eff21d3e278844e4dc1

PKG_MAINTAINER:=Volker Christian <me@vchrist.at>

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=toolchain

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/easyloggingpp
  SECTION:=lib
  CATEGORY:=Libraries
  TITLE:=Easylogging - A single header C++ Logging Library
  URL:=https://github.com/abumq/easyloggingpp
endef

define Package/easyloggingpp/description
  Easylogging++ is single header efficient logging library for C++ applications. It is extremely powerful, highly extendable and configurable to user's requirements.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/easylogging++.h $(1)/usr/include
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/easylogging++.cc $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/pkgconfig/easyloggingpp.pc $(1)/usr/lib/pkgconfig
endef

$(eval $(call BuildPackage,easyloggingpp))
