#
# Copyright (C) 2021 Nir Izraeli <niriz@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gitea
PKG_VERSION:=1.14.2
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-src-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/go-gitea/gitea/releases/download/v$(PKG_VERSION)/
# https://github.com/go-gitea/gitea/releases/download/v1.14.2/gitea-src-1.14.2.tar.gz
PKG_HASH:=d04bca934feba35600aaf739c82b7cbe7d8b911a086d7ac54f0710b689a85ac3

PKG_BUILD_DIR:=$(BUILD_DIR)/golang-${PKG_NAME}-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

# GO_PKG:=github.com/go-gitea/gitea
GO_PKG:=code.gitea.io

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

PKG_UNPACK:=$(HOST_TAR) -C "$(PKG_BUILD_DIR)" -xzf "$(DL_DIR)/$(PKG_SOURCE)"

define Package/gitea
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Version Control Systems
  DEPENDS:= \
	+git \
	+golang \
	$(GO_ARCH_DEPENDS)

  TITLE:=Web administration of git repositories
  URL:=https://gitea.com/
  USERID:=git=382:git=382
  MAINTAINER:=Nir Izraeli <nirizr@gmail.com>
endef

define Package/gitea/description
  Gitea: Git with a cup of tea
  git management with a web interface
endef

#define Build/Configure
#	true
#endef

GO_PKG_INSTALL_ALL:=1
MAKE_VARS += $(GO_PKG_VARS)
MAKE_FLAGS += COMMIT=$(PKG_SOURCE_VERSION)

ifeq ($(ARCH),mips)
MAKE_FLAGS += EXTRA_FLAGS='-buildmode=default'
# Remove unsupported linker flags
TARGET_LDFLAGS := $(echo "${TARGET_LDFLAGS}" | sed 's/-znow -zrelro//')
# Add missing spaces between -L flag and it's argument (if no space)
TARGET_LDFLAGS := $(echo "${TARGET_LDFLAGS}" | sed 's/-L[^\s]/-L /')
endif

define Build/Compile
	+$(MAKE_VARS) \
	$(GO_PKG_VARS) \
	TAGS="bindata " \
	$(MAKE) $(PKG_JOBS) -C $(GO_PKG_BUILD_DIR)/src/$(GO_PKG) \
		$(MAKE_FLAGS)
endef

# define Build/install
# 	true
# endef

# define Package/gitea/install
# 	true
# endef

$(eval $(call GoBinPackage,gitea))
$(eval $(call BuildPackage,gitea))
