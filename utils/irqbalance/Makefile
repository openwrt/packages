# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=irqbalance
PKG_VERSION:=1.9.3
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Irqbalance/irqbalance.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=ff2936e9b7486e802206cbf9e16aa6cb7e1501bdf502441d31f409d104e757b8

PKG_MAINTAINER:=Hannu Nyman <hannu.nyman@iki.fi>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

PKG_BUILD_DEPENDS += glib2

define Package/irqbalance
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=$(ICONV_DEPENDS) $(INTL_DEPENDS)
  TITLE:=IRQ usage balancing for multi-core systems
  URL:=https://github.com/Irqbalance/irqbalance
endef

define Package/irqbalance/description
 The purpose of irqbalance is to distribute hardware interrupts across
 processors/cores on a multiprocessor/multicore system in order to
 increase performance.
endef

define Package/irqbalance/conffiles
/etc/config/irqbalance
endef

MESON_ARGS += \
	-Dcapng=disabled \
	-Dui=disabled

define Package/irqbalance/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/irqbalance $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/irqbalance.init $(1)/etc/init.d/irqbalance
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/irqbalance.config $(1)/etc/config/irqbalance
endef

$(eval $(call BuildPackage,irqbalance))
