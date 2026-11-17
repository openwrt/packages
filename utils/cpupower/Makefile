include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=cpupower
PKG_VERSION:=$(LINUX_VERSION)
PKG_RELEASE:=1

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/cpupower
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Shows and sets processor power related values
  URL:=https://www.kernel.org
  DEPENDS:=+libpci
endef

define Package/cpupower/description
  Linux kernel tool to examine and to tune power saving related features of the processor
endef

MAKE_FLAGS = \
	ARCH="$(LINUX_KARCH)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS/ -fhonour-copts/) $(TARGET_CPPFLAGS) -I$(STAGING_DIR)/usr/include" \
	LDFLAGS="$(TARGET_LDFLAGS) -L$(STAGING_DIR)/usr/lib" \
	CPUFREQ_BENCH=false \
	NLS=false

define Build/Compile
	sed -i '/^CROSS/d' $(LINUX_DIR)/tools/power/cpupower/Makefile
	-$(MAKE) clean -C $(LINUX_DIR)/tools/power/cpupower
	+$(MAKE) -C $(LINUX_DIR)/tools/power/cpupower $(MAKE_FLAGS)
endef

define Package/cpupower/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(LINUX_DIR)/tools/power/cpupower/cpupower $(1)/usr/bin/
	$(CP) $(LINUX_DIR)/tools/power/cpupower/libcpu* $(1)/usr/lib
endef

$(eval $(call BuildPackage,cpupower))
