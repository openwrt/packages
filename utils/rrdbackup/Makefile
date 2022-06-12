include $(TOPDIR)/rules.mk

PKG_NAME:=rrdbackup
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_LICENSE:=Unlicense

include $(INCLUDE_DIR)/package.mk

define Package/rrdbackup
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Enable the backup and restore of the RRD database for collectd during orderly reboots
  URL:=https://github.com/sqrwf/openwrt-rrdbackup
  PKGARCH:=all
  MAINTAINER:=John Kohl <jtk.git@bostonpog.org>
  EXTRA_DEPENDS:=luci-app-statistics
endef

define Package/rrdbackup/description
 rrdbackup provides a startup/shutdown script that backs up the RRD collectd
 database to flash and restores it to volatile storage during orderly reboots.
endef

define Package/rrdbackup/conffiles
/etc/collectd/rrdbackup.tgz
endef

define Build/Compile
endef

define Build/Configure
endef

define Build/Install
endef

define Package/rrdbackup/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/rrdbackup $(1)/etc/init.d/rrdbackup
endef

$(eval $(call BuildPackage,rrdbackup))
