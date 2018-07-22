include $(TOPDIR)/rules.mk

PKG_NAME:=iotop
PKG_VERSION:=0.6
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/iotop-$(PKG_VERSION)
PKG_SOURCE:=iotop-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://guichaz.free.fr/iotop/files
PKG_HASH:=1a7c02fd3758bb048d8af861c5f8735eb3ee9abadeaa787f27b8af2b1eaee8ce


include $(INCLUDE_DIR)/package.mk

define Package/iotop
  SECTION:=admin
  CATEGORY:=Administration
  DEPENDS:=+python-base +python-light +python-ncurses +python-codecs +python-ctypes
  TITLE:=simple top-like I/O monitor
  KCONFIG:= \
	CONFIG_TASKSTATS=y \
	CONFIG_TASK_DELAY_ACCT=y \
	CONFIG_TASK_XACCT=y \
	CONFIG_TASK_IO_ACCOUNTING=y \
	CONFIG_VM_EVENT_COUNTERS=y
  URL:=http://guichaz.free.fr/iotop/
endef

define Package/bridge/description
 simple top-like I/O monitor
 Iotop is a Python program with a top like UI used to show of behalf of which process is the I/O going on.
endef

define Build/Compile
endef

define Package/iotop/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/lib/python2.7
	$(CP) $(PKG_BUILD_DIR)/sbin/iotop $(1)/usr/sbin/
	$(CP) $(PKG_BUILD_DIR)/iotop $(1)/usr/lib/python2.7/
endef

$(eval $(call BuildPackage,iotop))
