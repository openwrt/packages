# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=irqbalance
PKG_VERSION:=1.2.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Irqbalance/irqbalance.git
PKG_SOURCE_VERSION:=0e0dd4cfe5464de2f81eaef504eab7183f1fb030
PKG_MIRROR_HASH:=c826e78babfc26f777a5791b2a6ea95b61453ba3e3c5803d4428cc803216bc5c
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE:=GPLv2

PKG_MAINTAINER:=Hannu Nyman <hannu.nyman@iki.fi>

PKG_FIXUP:=autoreconf
PKG_REMOVE_FILES:=autogen.sh

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/irqbalance
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=IRQ usage balancing for multi-core systems
  URL:=https://github.com/Irqbalance/irqbalance
endef

define Package/irqbalance/description
 The purpose of irqbalance is to distribute hardware interrupts across
 processors/cores on a multiprocessor/multicore system in order to
 increase performance.
endef

CONFIGURE_ARGS+= \
	--disable-numa \
	--with-libcap_ng=no \
	--with-systemd=no \
	--without-glib2

define Package/irqbalance/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/irqbalance $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,irqbalance))
