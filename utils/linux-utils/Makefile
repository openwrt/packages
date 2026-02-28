include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=linux-utils
PKG_VERSION:=$(LINUX_VERSION)
PKG_RELEASE:=1

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/linux-utils/Default
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=https://www.kernel.org
endef

define Package/cpupower
  $(call Package/linux-utils/Default)
  TITLE:=Shows and sets processor power related values
  DEPENDS:=+libpci
endef

define Package/cpupower/description
  Linux kernel tool to examine and to tune power saving related features of the processor
endef

define Package/turbostat
  $(call Package/linux-utils/Default)
  TITLE:=Report processor frequency and idle statistics
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
	# Build cpupower
	sed -i '/^CROSS/d' $(LINUX_DIR)/tools/power/cpupower/Makefile
	-$(MAKE) clean -C $(LINUX_DIR)/tools/power/cpupower
	+$(MAKE) -C $(LINUX_DIR)/tools/power/cpupower \
		$(MAKE_FLAGS) \
		CPUFREQ_BENCH=false \
		NLS=false

ifdef CONFIG_PACKAGE_turbostat
	#Build turbostat
	sed -i '/^CROSS/d' $(LINUX_DIR)/tools/power/x86/turbostat/Makefile
	-$(MAKE) clean -C $(LINUX_DIR)/tools/power/x86/turbostat
	+$(MAKE) -C $(LINUX_DIR)/tools/power/x86/turbostat $(MAKE_FLAGS)
endif
endef

define Package/cpupower/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(LINUX_DIR)/tools/power/cpupower/cpupower $(1)/usr/bin/
	$(CP) $(LINUX_DIR)/tools/power/cpupower/libcpu* $(1)/usr/lib
endef

define Package/turbostat/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(LINUX_DIR)/tools/power/x86/turbostat/turbostat $(1)/usr/bin/
endef

$(eval $(call BuildPackage,cpupower))
$(eval $(call BuildPackage,turbostat))
