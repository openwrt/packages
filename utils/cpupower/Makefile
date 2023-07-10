include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=cpupower
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0-only

PKG_VERSION:=$(shell basename $(LINUX_DIR) | sed 's/linux-//')
PKG_SOURCE:=
PKG_SOURCE_URL:=
PKG_HASH:=unknown

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>

define prepare_source_directory
	rm -rf $(PKG_BUILD_DIR)
	$(CP) $(LINUX_DIR)/tools/power/cpupower $(PKG_BUILD_DIR)
	mkdir -p $(PKG_BUILD_DIR)/scripts
	$(CP) $(LINUX_DIR)/tools/scripts/Makefile.arch $(PKG_BUILD_DIR)/scripts
endef

Hooks/Prepare/Pre += prepare_source_directory

include $(INCLUDE_DIR)/package.mk

define Package/cpupower
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Shows and sets processor power related values
  DEPENDS:=+libpci
  URL:=https://www.kernel.org
endef

define Package/cpupower/description
  Linux kernel tool to examine and to tune power saving related features of the processor
endef

define Build/Compile/cpupower
	$(MAKE) CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" DESTDIR=fake install-tools
endef

define Build/Compile
	(cd $(PKG_BUILD_DIR); $(call Build/Compile/cpupower))
endef

define Package/cpupower/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cpupower $(1)/usr/bin/
	$(CP) $(PKG_BUILD_DIR)/libcpu* $(1)/usr/lib
endef

$(eval $(call BuildPackage,cpupower))
