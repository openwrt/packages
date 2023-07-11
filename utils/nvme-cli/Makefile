# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Luca Barbato

include $(TOPDIR)/rules.mk

PKG_NAME:=nvme-cli
PKG_VERSION:=2.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/linux-nvme/nvme-cli/archive/refs/tags/v$(PKG_VERSION)
PKG_HASH:=e84bdba276aadcddda8cf5d412e934cc5673af15132ea02180deb5d06af73146

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Luca Barbato <lu_zero@luminem.org>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/nvme-cli
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Filesystem
  TITLE:=NVMe management command line interface
  URL:=https://nvmexpress.org/
  DEPENDS:=+libnvme 
endef

define Package/nvme-cli/description
  NVM-Express user space tooling for Linux.
endef

define Package/nvme-cli/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/nvme $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,nvme-cli))
