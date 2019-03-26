#
# Copyright (C) 2018 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=golang-torproject-pluggable-transports-goptlib
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://git.torproject.org/pluggable-transports/goptlib.git
PKG_SOURCE_VERSION:=7d56ec4f381e8b1aedfda360594e35a5731b5337
PKG_SOURCE_DATE:=20180320
PKG_MIRROR_HASH:=ec28d8882e031046efd561764e1b9119376844a1c3d4941e038cfbe32e60b058

PKG_LICENSE:=CC0-1.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1

GO_PKG:=git.torproject.org/pluggable-transports/goptlib.git
GO_PKG_SOURCE_ONLY:=1

include $(INCLUDE_DIR)/package.mk
include ../golang-package.mk

define Package/golang-torproject-pluggable-transports-goptlib-dev
$(call GoPackage/GoSubMenu)
  TITLE:=Tor pluggable transports library for Go
  URL:=https://gitweb.torproject.org/pluggable-transports/goptlib.git/
  DEPENDS:=$(GO_ARCH_DEPENDS)
  PKGARCH:=all
endef

define Package/golang-torproject-pluggable-transports-goptlib-dev/description
goptlib is a library for writing Tor pluggable transports in Go.
endef

$(eval $(call GoSrcPackage,golang-torproject-pluggable-transports-goptlib-dev))
$(eval $(call BuildPackage,golang-torproject-pluggable-transports-goptlib-dev))
