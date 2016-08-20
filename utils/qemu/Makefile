#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qemu
PKG_VERSION:=2.5.0
PKG_RELEASE:=1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://wiki.qemu-project.org/download/
PKG_SOURCE_MD5SUM:=f469f2330bbe76e3e39db10e9ac4f8db
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE tcg/LICENSE
PKG_MAINTAINER:=Yousong Zhou <yszhou4tech@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/qemu-ga
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=QEMU Guest Agent
  URL:=http://www.qemu.org
  DEPENDS:=+glib2 +libpthread +libstdcpp +librt
endef

define Package/qemu-ga/description
This package contains the QEMU Guest Agent daemon
endef

# QEMU configure script does not recognize these options
CONFIGURE_ARGS:=$(filter-out	\
	--target=%		\
	--host=%		\
	--build=%		\
	--program-prefix=%	\
	--program-suffix=%	\
	--exec-prefix=%		\
	--disable-nls		\
	, $(CONFIGURE_ARGS))

# Building qemu-ga alone does not require zlib, pixman
#
# --disable-tools to disable building pixman which will fail at the moment on
#  octeon mips64 target.
CONFIGURE_ARGS +=			\
	--cross-prefix=$(TARGET_CROSS)	\
	--host-cc="$(HOSTCC)"		\
	--target-list=''		\
	--disable-zlib-test		\
	--disable-tools			\
	--without-pixman

ifneq ($(CONFIG_PACKAGE_qemu-ga),)
CONFIGURE_ARGS += --enable-guest-agent
endif

MAKE_VARS += V=s

define Build/Compile
	$(if $(CONFIG_PACKAGE_qemu-ga),$(call Build/Compile/Default,qemu-ga))
endef

define Package/qemu-ga/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/qemu-ga $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/qemu-ga.init $(1)/etc/init.d/qemu-ga
	$(INSTALL_DIR) $(1)/etc/hotplug.d/virtio-ports
	$(INSTALL_BIN) ./files/virtio-ports.hotplug $(1)/etc/hotplug.d/virtio-ports/qemu-ga
endef

$(eval $(call BuildPackage,qemu-ga))
