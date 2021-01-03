#
# Copyright (C) 2020 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gitlab-runner
PKG_VERSION:=13.5.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://gitlab.com/gitlab-org/gitlab-runner/-/archive/v$(PKG_VERSION)
PKG_HASH:=765c1556ed9dd4c1b36f9946224c62f068b171e2c1581eeb8f71055327d8a274

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
  DEPENDS:= \
    $(GO_ARCH_DEPENDS) \
    @!(mips||mipsel) # Disabled because of docker engine error https://gitlab.com/gitlab-org/gitlab-runner/-/issues/27234
endef

define Package/gitlab-runner/description
  GitLab Runner is an application that works with
  GitLab CI/CD to run jobs in a pipeline.
endef

$(eval $(call GoBinPackage,gitlab-runner))
$(eval $(call BuildPackage,gitlab-runner))
