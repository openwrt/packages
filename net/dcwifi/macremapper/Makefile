#
# Copyright (C) 2019 EWSI
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=macremapper
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ewsi/$(PKG_NAME)/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=f054201dd805ce005b89606a507b58a5717d383a4339c69dfdc02f0202935437

PKG_MAINTAINER:=Carey Sonsino <careys@edgewaterwireless.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=kernelmod/COPYING

include $(INCLUDE_DIR)/package.mk

define KernelPackage/macremapper
  SUBMENU:=Network Support
  URL:=https://www.edgewaterwireless.com
  VERSION:=$(LINUX_VERSION)-$(BOARD)-$(PKG_RELEASE)
  TITLE:=Dual Channel Wi-Fi macremapper Module
  DEPENDS:= +kmod-cfg80211 +kmod-br-netfilter
  FILES:=$(PKG_BUILD_DIR)/kernelmod/$(PKG_NAME).$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoProbe,macremapper)
endef

define KernelPackage/macremapper/description
  Linux kernel module for implementation the DCW filtering mechanism
endef

MAKE_FLAGS += KERNEL_SRC=$(LINUX_DIR)
MAKE_PATH:=kernelmod

$(eval $(call KernelPackage,macremapper))
