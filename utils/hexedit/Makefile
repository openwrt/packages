#
# Copyright (C) 2022 Nita Vesa
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=hexedit
PKG_VERSION:=1.6
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/pixel/hexedit.git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_MIRROR_HASH:=3f35954fc051b86aa6255bf0841bc774fd6fa8fba46e3feb6945b88b0d2f56fa

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Nita Vesa <werecatf@outlook.com>

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/hexedit
  TITLE:=Viewer and editor in hexadecimal or ASCII
  SUBMENU:=Editors
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=http://rigaux.org/hexedit.html
  DEPENDS:=+libncurses
endef

define Package/hexedit/description
  Viewer and editor in hexadecimal or ASCII for files or devices

  hexedit shows a target both in hexadecimal and in ASCII. This target can be
  a device or a file. You can edit the target and search through it. There are
  also copy&paste and save to file functions. Is allowed truncating or appending
  to the target. All modifications are shown in bold.

  hexedit is ideal to edit or inspect very large files or devices, as hard disks
  or its partitions, flash drives, etc. These elements will not be wholly read
  because hexedit loads a piece at a time.

  hexedit can be used by programmers in several activities. It also is useful
  for debugging, forensics investigations and recovering from digital disasters.
endef

define Package/hexedit/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/hexedit $(1)/usr/bin/
endef

$(eval $(call BuildPackage,hexedit))
