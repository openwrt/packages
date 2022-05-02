#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=htop
PKG_VERSION:=3.2.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/htop-dev/htop/tar.gz/$(PKG_VERSION)?
PKG_HASH:=1a1dd174cc828521fe5fd0e052cff8c30aa50809cf80d3ce3a481c37d476ac54

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:htop:htop


PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_CONFIG_DEPENDS:= CONFIG_HTOP_LMSENSORS
PKG_BUILD_DEPENDS:= HTOP_LMSENSORS:lm-sensors

include $(INCLUDE_DIR)/package.mk

define Package/htop
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Interactive processes viewer
  DEPENDS:=+libncurses
  URL:=https://hisham.hm/htop/
  MAINTAINER:=Etienne CHAMPETIER <champetier.etienne@gmail.com>
endef

define Package/htop/description
 Htop is an ncursed-based process viewer similar to top, but
 it allows to scroll the list vertically and horizontally to
 see all processes and their full command lines.
endef

define Package/htop/config
	config HTOP_LMSENSORS
		bool "Compile Htop with lm-sensors support"
		depends on PACKAGE_htop
		default y if TARGET_x86
		help
			Build htop with lm-sensors support.
			This doesn't add lm-sensors as dependency,
			if present it'll loaded using dlopen().
endef

CONFIGURE_ARGS += \
	--$(if $(CONFIG_HTOP_LMSENSORS),en,dis)able-sensors \
	--enable-affinity \
	--disable-capabilities \
	--disable-delayacct \
	--disable-unicode \
	--disable-unwind \
	--disable-hwloc

CONFIGURE_VARS += \
	ac_cv_file__proc_stat=yes \
	ac_cv_file__proc_meminfo=yes

define Package/htop/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(1)/usr/bin/
endef

$(eval $(call BuildPackage,htop))
