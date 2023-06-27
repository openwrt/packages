include $(TOPDIR)/rules.mk

PKG_NAME:=speedtestcpp
PKG_VERSION:=1.20.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/oskarirauta/speedtestcpp/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=7d5c85f1d9a46f7d8a3ac4261ef1f92e53c511430bae096f7ec6f12a33d38904

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/libspeedtestcpp
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=library for ookla's speedtest
  DEPENDS:=+libcurl +libstdcpp
  URL:=https://github.com/oskarirauta/speedtestcpp
endef

define Package/libspeedtestcpp/description
  Shared library that provides support for ookla's speedtest
endef

define Package/speedtestcpp
  SECTION:=net
  CATEGORY:=Network
  TITLE:=SpeedTest++
  DEPENDS:=+libspeedtestcpp +libstdcpp
  URL:=https://github.com/oskarirauta/speedtestcpp
  PROVIDES:=speedtestpp
endef

define Package/speedtestcpp/description
  Yet another unofficial speedtest.net client cli interface
  forked from taganaka's SpeedTest with few improments and
  lesser depends.
endef

TARGET_CXXFLAGS += --std=c++23 -fPIC

define Build/Configure
endef

define Package/libspeedtestcpp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libspeedtestcpp.so* $(1)/usr/lib/
endef

define Package/speedtestcpp/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/speedtest $(1)/usr/bin/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib $(1)/usr/include/speedtest
	$(CP) $(PKG_BUILD_DIR)/libspeedtestcpp.{so*,a} $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/include/speedtest/*.hpp $(1)/usr/include/speedtest/
endef

$(eval $(call BuildPackage,libspeedtestcpp))
$(eval $(call BuildPackage,speedtestcpp))
