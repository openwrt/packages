# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=irqbalance
PKG_VERSION:=1.7.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Irqbalance/irqbalance.git
PKG_SOURCE_VERSION:=641edc6f5d56f1b3eb8be0fa8a8e9b6a22e53218
PKG_MIRROR_HASH:=c5453159f4863f7a37a1afa170a5db475c866a5a34975bcc427a22a8b3b97701
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE:=GPLv2

PKG_MAINTAINER:=Hannu Nyman <hannu.nyman@iki.fi>

PKG_FIXUP:=autoreconf
PKG_REMOVE_FILES:=autogen.sh

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/nls.mk

include $(INCLUDE_DIR)/package.mk

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

CONFIGURE_ARGS+= \
	--disable-numa \
	--with-libcap_ng=no \
	--with-systemd=no \
	--without-irqbalance-ui \
	--enable-static=glib2

GLIB2_LIBS="$(STAGING_DIR)/usr/lib/libglib-2.0.a"

ifeq ($(CONFIG_BUILD_NLS),y)
	GLIB2_LIBS += $(INTL_LDFLAGS) -lintl
endif

ifeq ($(CONFIG_USE_GLIBC),y)
	GLIB2_LIBS += -lpthread
endif

CONFIGURE_VARS += \
	GLIB2_LIBS="$(GLIB2_LIBS) \
		$(ICONV_LDFLAGS) -liconv"

define Package/irqbalance/conffiles
/etc/config/irqbalance
endef

define Package/irqbalance/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/irqbalance $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/irqbalance.init $(1)/etc/init.d/irqbalance
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/irqbalance.config $(1)/etc/config/irqbalance
endef

$(eval $(call BuildPackage,irqbalance))
