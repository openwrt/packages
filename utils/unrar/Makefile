#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=unrar
PKG_VERSION:=5.7.3
PKG_RELEASE:=1

PKG_SOURCE:=unrarsrc-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.rarlab.com/rar
PKG_HASH:=40e856b78374f258d8a1f5f02c02f828c5392a0118c9300fd169a300b520a444
PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>, \
		Ted Hess <thess@kitschensync.net>

PKG_LICENSE:=UnRAR
PKG_LICENSE_FILES:=license.txt
PKG_CPE_ID:=cpe:/a:rarlab:unrar

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-$(BUILD_VARIANT)/unrar
PKG_INSTALL:=1

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

ifeq ($(CONFIG_USE_UCLIBCXX),y)
TARGET_LDFLAGS +=-nodefaultlibs
endif
TARGET_CXXFLAGS +=-fno-rtti -flto
TARGET_LDFLAGS +=$(FPIC) -Wl,--gc-sections

define Package/unrar/Default
  TITLE:=UnRAR
  SUBMENU:=Compression
  URL:=https://www.rarlab.com/
  DEPENDS:=$(CXX_DEPENDS) +libpthread
endef

define Package/unrar
$(call Package/unrar/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE+= (application)
  VARIANT:=bin
endef

define Package/libunrar
$(call Package/unrar/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+= (library)
  VARIANT:=lib
endef

define Package/unrar/description
  UnRAR is an application that can decompress files and archives created using
  the RAR compression scheme
endef

define Package/libunrar/description
  UnRAR library is a shared library that provides file extraction from RAR
  archives
endef

ifeq ($(BUILD_VARIANT),lib)
define Build/Compile
	$(call Build/Compile/Default,lib)
endef

define Build/Install
	$(call Build/Install/Default,install-lib)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/unrar
	$(CP) $(PKG_BUILD_DIR)/*.hpp $(1)/usr/include/unrar/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libunrar.so $(1)/usr/lib/
endef
else
define Build/Compile
	$(call Build/Compile/Default,unrar)
endef

define Build/Install
	$(call Build/Install/Default,install-unrar)
endef
endif

define Package/unrar/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/unrar $(1)/usr/bin/
endef

define Package/libunrar/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libunrar.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,unrar))
$(eval $(call BuildPackage,libunrar))
