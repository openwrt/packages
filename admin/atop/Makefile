#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/nls.mk

PKG_NAME:=atop
PKG_VERSION:=2.13.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.atoptool.nl/download/
PKG_HASH:=ea182f84c9f52ca922e5af4f17dff97ff424400a4f2f92393317a6af66e6a874

PKG_MAINTAINER:=Toni Uhlig <matzeton@googlemail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:atop_project:atop

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -DNCURSES_WIDECHAR=1

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
	$(LN) atop $(1)/usr/bin/atopsar
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) ./files/atop-daily $(1)/usr/libexec/atop-daily
	$(INSTALL_DIR) $(1)/etc/default
	$(INSTALL_CONF) ./files/atop.default $(1)/etc/default/atop
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/atop.init $(1)/etc/init.d/atop
endef

define Package/atop/conffiles
/etc/default/atop
endef

$(eval $(call BuildPackage,atop))
