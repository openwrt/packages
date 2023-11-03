#
# Copyright (C) 2020-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gitlab-runner
PKG_VERSION:=16.0.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://gitlab.com/gitlab-org/gitlab-runner/-/archive/v$(PKG_VERSION)
PKG_HASH:=f874b9babe21ae04007abfc901e9ad4c0c1ec22095d4de3e22e176914683cb5d

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/gitlab-runner-v$(PKG_VERSION)
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=gitlab.com/gitlab-org/gitlab-runner
GO_PKG_LDFLAGS_X:=$(GO_PKG)/common.VERSION=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/gitlab-runner
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=Runner for CI/CD
  URL:=https://docs.gitlab.com/runner
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/gitlab-runner/description
  GitLab Runner is an application that works with
  GitLab CI/CD to run jobs in a pipeline.
endef

define Package/gitlab-runner/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gitlab-runner $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gitlab-runner-helper $(1)/usr/bin/
endef

$(eval $(call GoBinPackage,gitlab-runner))
$(eval $(call BuildPackage,gitlab-runner))
