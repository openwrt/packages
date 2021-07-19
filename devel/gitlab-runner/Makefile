#
# Copyright (C) 2020-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gitlab-runner
PKG_VERSION:=14.0.1
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://gitlab.com/gitlab-org/gitlab-runner/-/archive/v$(PKG_VERSION)
PKG_HASH:=22fe41816bb288c6f6513214f0d1d68d33d298aeaa9cd3a4f0a8393e6b20415f

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/gitlab-runner-v$(PKG_VERSION)
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
GO_PKG:=gitlab.com/gitlab-org/gitlab-runner

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

$(eval $(call GoBinPackage,gitlab-runner))
$(eval $(call BuildPackage,gitlab-runner))
