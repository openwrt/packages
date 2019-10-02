#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=procps-ng
PKG_VERSION:=3.3.15
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@SF/procps-ng
PKG_HASH:=10bd744ffcb3de2d591d2f6acf1a54a7ba070fdcc432a855931a5057149f0465

PKG_MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING COPYING.LIB

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_BUILD_DEPENDS:=gettext libiconv

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += --enable-skill

# most of these have alternatives provided by busybox applets
PROCPS_APPLETS := \
    free kill pgrep pkill pmap ps pwdx skill slabtop \
    snice tload top uptime vmstat w watch

# procps-ng will be configured with "--bindir=/usr/bin --sbindir=/usr/sbin" and
# as such executables will be installed there by default, but some of them need
# to reside in locations such as /bin and /sbin to be in accordance with
# busybox alternatives which is also other distributions like debian and centos
# are doing
PROCPS_APPLETS_DIR_bin:=kill ps watch
procps-applets-dir=$(if $(findstring $(1),$(PROCPS_APPLETS_DIR_bin)),/bin,/usr/bin)

define Package/procps-ng/Default
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libncurses
  TITLE:=procps-ng utilities
  URL:=https://gitlab.com/procps-ng/procps
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	echo "$(PKG_VERSION)" > "$(PKG_BUILD_DIR)/.tarball-version"
endef

define Package/procps-ng
  $(call Package/procps-ng/Default)
  MENU:=1
endef

define Package/procps-ng/description
  procps is a set of command line and full-screen utilities that provide information out of the pseudo-filesystem
  most commonly located at /proc. This filesystem provides a simple interface to the kernel data structures.
  The programs of procps generally concentrate on the structures that describe the processess running on the system.

  NOTE: some utilities provided by procps-ng packages (ps, uptime, kill, ...) are installed as busybox applets, by default.
  Conflicting applets should be removed from the build to avoid file conflicts.
endef

define GenPlugin
 define Package/$(1)
   $(call Package/procps-ng/Default)
   DEPENDS:=procps-ng
   TITLE:=Applet $(2) from the procps-ng package
   DEFAULT:=n
   ALTERNATIVES:=200:$(3)/$(2):$(3)/$(1)
 endef

 define Package/$(1)/description
  Installs the applet $(2).
 endef
endef

$(foreach a,$(PROCPS_APPLETS),$(eval $(call GenPlugin,procps-ng-$(a),$(a),$(call procps-applets-dir,$(a)))))

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \

define Package/procps-ng/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libprocps.so* $(1)/usr/lib/
endef

define BuildPlugin
  define Package/$(1)/install
	$(INSTALL_DIR) $$(1)$(3)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(2) $$(1)$(3)/$(1)
  endef

  $$(eval $$(call BuildPackage,$(1)))
endef

$(foreach a,$(PROCPS_APPLETS),$(eval $(call BuildPlugin,procps-ng-$(a),$(a),$(call procps-applets-dir,$(a)))))
$(eval $(call BuildPackage,procps-ng))
