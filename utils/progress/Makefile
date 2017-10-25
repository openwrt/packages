#
# Copyright (C) 2016 Nikil Mehta <nikil.mehta@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=progress
PKG_VERSION:=0.13.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Xfennec/progress.git
PKG_SOURCE_VERSION:=f6894b827c638af5cf8c5c622e66491c179ba2eb
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.xz
PKG_MIRROR_HASH:=143047dd44f78c10763446097bcadc551e99a7a8fefc484ef5a65d7bcbe8c181

PKG_MAINTAINER:=Nikil Mehta <nikil.mehta@gmail.com>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/progress
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Coreutils Progress Viewer (formerly known as 'cv')
  URL:=https://github.com/Xfennec/progress
  DEPENDS:=+libncursesw
endef

define Package/progress/description
	This tool can be described as a Tiny, Dirty, Linux-and-OSX-Only
	C command that looks for coreutils basic commands (cp, mv, dd, tar,
	gzip/gunzip, cat, etc.) currently running on your system and
	displays the percentage of copied data. It can also show estimated
	time and throughput, and provide a "top-like" mode (monitoring).
	.
	It simply scans `/proc` for interesting commands, and then looks at
	directories `fd` and `fdinfo` to find opened files and seek positions,
	and reports status for the largest file.
	.
	It's very light, and compatible with virtually any command.
	This program was formerly known as 'cv' on github.
endef

define Package/progress/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/progress $(1)/usr/bin/
endef

$(eval $(call BuildPackage,progress))
