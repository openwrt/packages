#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/nls.mk

PKG_NAME:=atop
PKG_VERSION:=2.12.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.atoptool.nl/download/
PKG_HASH:=0d09ecc90c14e6ef41c22e3c57c142c3e4fb9cf3c94379077a33c961d5343086

PKG_MAINTAINER:=Toni Uhlig <matzeton@googlemail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:atop_project:atop

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/atop
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=System and process monitor for Linux
  DEPENDS:=+zlib +libncurses +glib2
  URL:=https://www.atoptool.nl/
endef

define Package/atop/description
  Atop is an ASCII full-screen performance monitor for
  Linux that is capable of reporting the activity of all
  processes (even if processes have finished during the
  interval), daily logging of system and process activity
  for long-term analysis, highlighting overloaded system
  resources by using colors, etcetera. At regular
  intervals, it shows system-level activity related to the
  CPU, memory, swap, disks (including LVM) and network
  layers, and for every process (and thread) it shows e.g.
  the CPU utilization, memory growth, disk utilization,
  priority, username, state, and exit code. In combination
  with the optional kernel module netatop, it even shows
  network activity per process/thread.
endef

define Package/atop/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/atop $(1)/usr/bin/
endef

$(eval $(call BuildPackage,atop))
