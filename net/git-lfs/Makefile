#
# Copyright (C) 2020-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=git-lfs
PKG_VERSION:=3.0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/git-lfs/git-lfs/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=ea47feff8cf10855393dd20f22a7168c462043c7a654a5fd0546af0a9d28a3a2

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.md

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/git-lfs/git-lfs

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/git-lfs
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Git Large File Storage
  URL:=https://git-lfs.github.com
  DEPENDS:=$(GO_ARCH_DEPENDS) +git
endef

define Package/git-lfs/description
  Git Large File Storage (LFS) replaces large files such as audio samples,
  videos, datasets, and graphics with text pointers inside Git, while storing
  the file contents on a remote server like GitHub.com or GitHub Enterprise.
endef

$(eval $(call GoBinPackage,git-lfs))
$(eval $(call BuildPackage,git-lfs))
