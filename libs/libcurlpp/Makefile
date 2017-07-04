include $(TOPDIR)/rules.mk

PKG_NAME:=libcurlpp
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/jpbarrette/curlpp.git
PKG_SOURCE_VERSION:=v0.8.1
PKG_SOURCE_DATE=2017-07-04
PKG_SOURCE_PROTO:=git

PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/$(PKG_NAME)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=cURLpp
  URL:=https://github.com/jpbarrette/curlpp
  DEPENDS:=+libcurl +libstdcpp
  MAINTAINER:=Navid Fathollahzade <yaa110@gmail.com>
endef

define Package/$(PKG_NAME)/description
	C++ wrapper around libcURL
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/include/curlpp $(1)/usr/include/utilspp $(1)/usr/lib $(1)/usr/lib/pkgconfig
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/curlpp-config $(1)/usr/bin/
	$(CP) -r $(PKG_INSTALL_DIR)/usr/include/curlpp/* $(1)/usr/include/curlpp
	$(CP) $(PKG_INSTALL_DIR)/usr/include/utilspp/* $(1)/usr/include/utilspp
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcurlpp.{a,so*} $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/extras/curlpp.pc $(1)/usr/lib/pkgconfig/
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libcurlpp.so.* $(1)/usr/lib
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
