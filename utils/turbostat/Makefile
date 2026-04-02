include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=turbostat
PKG_VERSION:=$(LINUX_VERSION)
PKG_RELEASE:=1

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/turbostat
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Report processor frequency and idle statistics
  URL:=https://www.kernel.org
  DEPENDS:=@(TARGET_x86_64||TARGET_x86) +libpci +libcap
endef

define Package/turbostat/description
  Turbostat reports processor topology, frequency, idle power-state statistics,
  temperature and power on X86 processors.
endef

MAKE_FLAGS = \
	ARCH="$(LINUX_KARCH)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS/ -fhonour-copts/) $(TARGET_CPPFLAGS) -I$(STAGING_DIR)/usr/include" \
	LDFLAGS="$(TARGET_LDFLAGS) -L$(STAGING_DIR)/usr/lib"

define Build/Compile
	sed -i '/^CROSS/d' $(LINUX_DIR)/tools/power/x86/turbostat/Makefile
	-$(MAKE) clean -C $(LINUX_DIR)/tools/power/x86/turbostat
	+$(MAKE) -C $(LINUX_DIR)/tools/power/x86/turbostat $(MAKE_FLAGS)
endef

define Package/turbostat/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(LINUX_DIR)/tools/power/x86/turbostat/turbostat $(1)/usr/bin/
endef

$(eval $(call BuildPackage,turbostat))
