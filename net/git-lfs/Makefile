#
# Copyright (C) 2020-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=git-lfs
PKG_VERSION:=3.4.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/git-lfs/git-lfs/releases/download/v$(PKG_VERSION)
PKG_HASH:=89acbe51799c5d7bdf6d8e6704fcd1a07735ee7d1ed67a0bc646a5d9a9d1099f

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.md

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/git-lfs/git-lfs

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/git-lfs
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Git Large File Storage
  URL:=https://git-lfs.com
  DEPENDS:=$(GO_ARCH_DEPENDS) +git
endef

define Package/git-lfs/description
  Git Large File Storage (LFS) replaces large files such as audio samples,
  videos, datasets, and graphics with text pointers inside Git, while storing
  the file contents on a remote server like GitHub.com or GitHub Enterprise.
endef

$(eval $(call GoBinPackage,git-lfs))
$(eval $(call BuildPackage,git-lfs))
