include $(TOPDIR)/rules.mk

PKG_NAME:=cpu-load-mon
PKG_VERSION=1.0
PKG_RELEASE:=1
MAINTAINER:=Nikita Kuchinsky <nik.owrt@serenity-island.net>

PKG_SOURCE=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeberg.org/sie-foss/cpu-load-mon/archive/$(PKG_VERSION).tar.gz?
PKG_HASH:=d43b47dbe2436e50554e16da87d50fdba5d7bba6fe78ad62ef5d12fdd7962d65

include $(INCLUDE_DIR)/package.mk

define Package/cpu-load-mon
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=CPU Load Monitor
	URL:=https://codeberg.org/sie-foss/cpu-load-mon
	PKGARCH:=all
	PROVIDES:=cpu-load-avg
endef

define Package/cpu-load-mon/description
CPU Load Monitor service written in awk (mawk).
Gathers CPU utilization data over time in the background and displays
averages over the last 1 min, 5 min, 15 min and overall (since boot).
endef

UNPACK_CMD=tar -xaf "$(DL_DIR)/$(PKG_SOURCE)" --directory $(PKG_BUILD_DIR)
SRC_DIR:=$(PKG_BUILD_DIR)/$(PKG_NAME)
define Build/Prepare
	$(call Build/Prepare/Default)
	sed -f ./files/strip-comments.sed $(SRC_DIR)/cpu-load-avg.awk       > $(PKG_BUILD_DIR)/cpu-load-avg.awk
	sed -f ./files/strip-comments.sed $(SRC_DIR)/cpu-load-stats-log.awk > $(PKG_BUILD_DIR)/cpu-load-stats-log.awk
	sed -f ./files/strip-comments.sed ./files/cpu-load-mon.init         > $(PKG_BUILD_DIR)/cpu-load-mon.init
	$(Build/Patch)
endef

define Build/Configure
endef
define Build/Compile
endef

define Package/cpu-load-mon/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/libexec $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_DATA) ./files/cpu-load-mon.conf $(1)/etc/config/$(PKG_NAME)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cpu-load-avg.awk $(1)/usr/bin/cpu-load-avg
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cpu-load-stats-log.awk $(1)/usr/libexec/cpu-load-stats-log.awk
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cpu-load-mon.init $(1)/etc/init.d/$(PKG_NAME)
endef

$(eval $(call BuildPackage,cpu-load-mon))

