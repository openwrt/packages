#
# Copyright (C) 2018 Lim Guo Wei
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=coremark
PKG_SOURCE_DATE:=2020-05-28
PKG_SOURCE_VERSION:=7685fd32bd7919581bfff2881a6dac6320581400
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_DATE).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/eembc/coremark/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_HASH:=ff7ee8b4d333893c1ea68616227b369581926d706c7df720b649e0a0631903a9
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_SOURCE_VERSION)

PKG_MAINTAINER:=Lim Guo Wei <limguowei@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE.md

include $(INCLUDE_DIR)/package.mk

define Package/coremark
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=CoreMark Embedded Microprocessor Benchmark
  URL:=https://github.com/eembc/coremark
endef

define Package/coremark/description
  Embedded Microprocessor Benchmark
endef

DIR_ARCH:=linux$(if $(CONFIG_ARCH_64BIT),64)

define Build/Compile
	$(SED) 's|EXE = .exe|EXE =|' $(PKG_BUILD_DIR)/$(DIR_ARCH)/core_portme.mak
	mkdir $(PKG_BUILD_DIR)/$(ARCH)
	$(CP) -r $(PKG_BUILD_DIR)/$(DIR_ARCH)/* $(PKG_BUILD_DIR)/$(ARCH)
	$(MAKE) -C $(PKG_BUILD_DIR) PORT_DIR=$(ARCH) $(MAKE_FLAGS) \
		compile 
endef

define Package/coremark/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/coremark $(1)/bin/
endef

$(eval $(call BuildPackage,coremark))
