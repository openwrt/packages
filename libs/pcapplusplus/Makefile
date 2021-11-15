#
# Copyright (C) 2021 Michal Hrusecky <michal.hrusecky@turris.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pcapplusplus
PKG_VERSION:=21.11
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-source-linux.tar.gz
PKG_HASH:=a936aa5b11dcb6d2ad764749d339fc683021bbf8badc1e493e17e61e50a1cbb1
PKG_SOURCE_URL:=https://github.com/seladb/PcapPlusPlus/releases/download/v$(PKG_VERSION)/

PKG_BUILD_DIR:=$(BUILD_DIR)/pcapplusplus-$(PKG_VERSION)-source-linux

PKG_LICENSE:=Unlicense
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/pcapplusplus
  SECTION:=net
  CATEGORY:=Network
  URL:=https://pcapplusplus.github.io/
  TITLE:=Library for getting information about the passing traffic
  DEPENDS:=+libpcap +libstdcpp
endef

define Build/Compile
	cd $(PKG_BUILD_DIR)/PcapPlusPlus; ./configure-linux.sh --install-dir /usr
	make -C $(PKG_BUILD_DIR)/PcapPlusPlus CXXFLAGS="$(TARGET_CXXFLAGS) -fPIC" CFLAGS="$(TARGET_CFLAGS) -fPIC" CXX=$(TARGET_CXX) CC=$(TARGET_CC) AR=$(TARGET_AR) libs
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/PcapPlusPlus/Dist/header/*.h $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	# Convert static libraries to shared ones
	$(TARGET_CXX) $(TARGET_CXXFLAGS) -shared -o $(1)/usr/lib/libCommon++.so -Wl,--whole-archive $(PKG_BUILD_DIR)/PcapPlusPlus/Dist/libCommon++.a -Wl,--no-whole-archive
	$(TARGET_CXX) $(TARGET_CXXFLAGS) -shared -o $(1)/usr/lib/libPacket++.so -Wl,--whole-archive $(PKG_BUILD_DIR)/PcapPlusPlus/Dist/libPacket++.a -Wl,--no-whole-archive
	$(TARGET_CXX) $(TARGET_CXXFLAGS) -shared -o $(1)/usr/lib/libPcap++.so -Wl,--whole-archive $(PKG_BUILD_DIR)/PcapPlusPlus/Dist/libPcap++.a -Wl,--no-whole-archive
	$(CP) $(PKG_BUILD_DIR)/PcapPlusPlus/Dist/lib*.a $(1)/usr/lib
endef

define Package/pcapplusplus/install
	$(INSTALL_DIR) $(1)/usr/lib
	# Convert static libraries to shared ones
	$(TARGET_CXX) $(TARGET_CXXFLAGS) -shared -o $(1)/usr/lib/libCommon++.so -Wl,--whole-archive $(PKG_BUILD_DIR)/PcapPlusPlus/Dist/libCommon++.a -Wl,--no-whole-archive
	$(TARGET_CXX) $(TARGET_CXXFLAGS) -shared -o $(1)/usr/lib/libPacket++.so -Wl,--whole-archive $(PKG_BUILD_DIR)/PcapPlusPlus/Dist/libPacket++.a -Wl,--no-whole-archive
	$(TARGET_CXX) $(TARGET_CXXFLAGS) -shared -o $(1)/usr/lib/libPcap++.so -Wl,--whole-archive $(PKG_BUILD_DIR)/PcapPlusPlus/Dist/libPcap++.a -Wl,--no-whole-archive
endef

$(eval $(call BuildPackage,pcapplusplus))
