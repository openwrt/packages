include $(TOPDIR)/rules.mk

PKG_NAME:=linux-utils
PKG_VERSION:=$(LINUX_VERSION)
PKG_RELEASE:=1

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/kernel.mk
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
	CFLAGS="$(TARGET_CFLAGS) -fhonour-copts $(TARGET_CPPFLAGS) -I$(STAGING_DIR)/usr/include" \
	LDFLAGS="$(TARGET_LDFLAGS) -L$(STAGING_DIR)/usr/lib"

ifneq ($(CONFIG_PACKAGE_cpupower),)
define Build/Compile/cpupower
	sed -i '/^CROSS/d' $(LINUX_DIR)/tools/power/cpupower/Makefile && \
	( $(MAKE) -C $(LINUX_DIR)/tools/power/cpupower clean || true ) && \
	$(MAKE) -C $(LINUX_DIR)/tools/power/cpupower \
		$(MAKE_FLAGS) \
		CPUFREQ_BENCH=false \
		NLS=false
endef
endif

ifneq ($(CONFIG_PACKAGE_turbostat),)
define Build/Compile/turbostat
	if [ -d $(LINUX_DIR)/tools/power/x86/turbostat ]; then \
		sed -i '/^CROSS/d' $(LINUX_DIR)/tools/power/x86/turbostat/Makefile && \
		( $(MAKE) -C $(LINUX_DIR)/tools/power/x86/turbostat clean || true ) && \
		$(MAKE) -C $(LINUX_DIR)/tools/power/x86/turbostat $(MAKE_FLAGS); \
	else \
		echo 'WARNING: turbostat source not found, skipping'; \
	fi
endef
endif

define Build/Compile
	$(Build/Compile/cpupower)
	$(Build/Compile/turbostat)
endef

define Package/cpupower/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(LINUX_DIR)/tools/power/cpupower/cpupower $(1)/usr/bin/
	$(CP) $(LINUX_DIR)/tools/power/cpupower/libcpu* $(1)/usr/lib
endef

define Package/turbostat/install
	if [ -f $(LINUX_DIR)/tools/power/x86/turbostat/turbostat ]; then \
		$(INSTALL_DIR) $(1)/usr/bin; \
		$(INSTALL_BIN) $(LINUX_DIR)/tools/power/x86/turbostat/turbostat $(1)/usr/bin/; \
	else \
		echo 'WARNING: turbostat binary not found, skipping install'; \
	fi
endef

$(eval $(call BuildPackage,cpupower))
$(eval $(call BuildPackage,turbostat))
