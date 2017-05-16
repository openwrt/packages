#
# Copyright (C) 2017 Bjørn Mork <bjorn@mork.no>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=iotop
PKG_VERSION:=0.6
PKG_RELEASE:=1
PKG_MAINTAINER:=Bjørn Mork <bjorn@mork.no>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://guichaz.free.fr/iotop/files/ \
	https://fossies.org/linux/misc/
PKG_HASH:=1a7c02fd3758bb048d8af861c5f8735eb3ee9abadeaa787f27b8af2b1eaee8ce

PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/iotop
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Simple top-like I/O monitor
  URL:=http://guichaz.free.fr/iotop/
  DEPENDS:=+python
  KCONFIG:=CONFIG_TASKSTATS=y \
    CONFIG_TASK_DELAY_ACCT=y \
    CONFIG_TASK_XACCT=y \
    CONFIG_TASK_IO_ACCOUNTING=y \
    CONFIG_VM_EVENT_COUNTERS=y
endef

define Package/iotop/description
 iotop does for I/O usage what top(1) does for CPU usage. It watches I/O
 usage information output by the Linux kernel and displays a table of
 current I/O usage by processes on the system. It is handy for answering
 the question "Why is the disk churning so much?".
endef

define Build/Compile
	$(call Build/Compile/PyMod,,\
		install --prefix=/usr --root="$(PKG_INSTALL_DIR)" \
	)
endef

define PyPackage/iotop/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/* $(1)/usr/sbin/
endef

$(eval $(call PyPackage,iotop))
$(eval $(call BuildPackage,iotop))
