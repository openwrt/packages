include $(TOPDIR)/rules.mk

PKG_NAME:=easyloggingpp
PKG_VERSION:=9.97.0
PKG_RELEASE:=1

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/abumq/easyloggingpp/archive/refs/tags
PKG_HASH:=9110638e21ef02428254af8688bf9e766483db8cc2624144aa3c59006907ce22
PKG_MAINTAINER:=Volker Christian <me@vchrist.at>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# Package definition; instructs on how and where our package will appear in the overall configuration menu ('make menuconfig')
define Package/easyloggingpp
  SECTION:=lib
  CATEGORY:=Libraries
  TITLE:=Easylogging C++ Library
endef

# Package description; a more verbose description on what our package does
define Package/easyloggingpp/description
  Simplifies logging in C++ code
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/easylogging++.h $(1)/usr/include
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/easylogging++.cc $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/pkgconfig/easyloggingpp.pc $(1)/usr/lib/pkgconfig
endef

# This command is always the last, it uses the definitions and variables we give above in order to get the job done
$(eval $(call BuildPackage,easyloggingpp))
