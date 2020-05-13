#
# Copyright (C) 2018 Lim Guo Wei
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=coremark
PKG_SOURCE_DATE:=2020-01-19
PKG_SOURCE_VERSION:=0c91314d1a4fdfc157d623ad5cb6ac5aef746db1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_DATE).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/eembc/coremark/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_HASH:=ed046fc8b4402090a9a4aaea14013489c3184617da493a70c7576da69efea8ba
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

define Build/Compile
	$(SED) 's|EXE = .exe|EXE =|' $(PKG_BUILD_DIR)/linux/core_portme.mak
	mkdir $(PKG_BUILD_DIR)/$(ARCH)
	$(CP) -r $(PKG_BUILD_DIR)/linux/* $(PKG_BUILD_DIR)/$(ARCH)
	$(MAKE) -C $(PKG_BUILD_DIR) PORT_DIR=$(ARCH) $(MAKE_FLAGS) \
		compile 
endef

define Package/coremark/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/coremark $(1)/bin/
endef

$(eval $(call BuildPackage,coremark))
