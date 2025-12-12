include $(TOPDIR)/rules.mk

PKG_NAME:=flent
PKG_VERSION:=2.2.0
PKG_RELEASE:=2

PYPI_NAME:=flent
PKG_HASH:=04fc21de858863560423e79c822f405225f829afd8e5d62293099fbef341f9e8

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

include ../../lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../../lang/python/python3-package.mk

define Package/flent
  SECTION:=net
  CATEGORY:=Network
  TITLE:=The FLExible Network Tester
  URL:=https://flent.org
  CONFLICTS:=python3-flent
  DEPENDS:= \
    +python3-light \
    +python3-uuid \
    +python3-logging \
    +python3-defusedxml \
    +flent-tools \
    +netperf \
    +fping
endef

define Package/flent/description
  Flent is a Python wrapper to run multiple simultaneous
  netperf/iperf/ping instances and aggregate the results.
endef


define Package/flent-tools
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Helper programs for the Flent test tool
  URL:=https://flent.org
  DEPENDS+=+librt +coreutils-sleep +coreutils-date
endef

define Package/flent-tools/description
	This builds the C helper programs for gathering data for
	the Flent network testing tool. These tools are needed for
	gathering data when a Bash shell is not available (and also
	perform better than the shell equivalents).
endef

define Build/Compile/flent-tools
	$(MAKE) -C $(PKG_BUILD_DIR)/misc \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -std=gnu99"
endef

define Package/flent-tools/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/misc/tc_iterate $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/misc/wifistats_iterate $(1)/usr/sbin/
endef

define Build/Compile
	$(call Py3Build/Compile)
	$(call Build/Compile/flent-tools)
endef

$(eval $(call Py3Package,flent))
$(eval $(call BuildPackage,flent))
$(eval $(call BuildPackage,flent-src))
$(eval $(call BuildPackage,flent-tools))
