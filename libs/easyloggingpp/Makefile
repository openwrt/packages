include $(TOPDIR)/rules.mk

PKG_NAME:=easyloggingpp
PKG_VERSION:=9.97.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/abumq/easyloggingpp/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=9110638e21ef02428254af8688bf9e766483db8cc2624144aa3c59006907ce22

PKG_MAINTAINER:=Volker Christian <me@vchrist.at>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/easyloggingpp
  SECTION:=lib
  CATEGORY:=Libraries
  TITLE:=A single header C++ Logging Library
  URL:=https://github.com/abumq/easyloggingpp
  BUILDONLY:=1
endef

define Package/easyloggingpp/description
  Easylogging++ is single header efficient logging library for C++
  applications. It is extremely powerful, highly extendable and
  configurable to user's requirements.
endef

$(eval $(call BuildPackage,easyloggingpp))
