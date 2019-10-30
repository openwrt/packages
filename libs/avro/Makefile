#
# avro - Makefile for Apache Avro library
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=avro-c
PKG_VERSION:=1.9.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@APACHE/avro/avro-$(PKG_VERSION)/c
PKG_HASH:=7df7bc1e13ce7180f0438ed05ab6642b5b2b6df91f30b927b470e25a78e04642

PKG_MAINTAINER:=John Clark <inindev@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/avro-c
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+jansson +zlib +liblzma
  TITLE:=Apache Avro C Library
  URL:=https://avro.apache.org
endef

define Package/avro-c/description
  This package contains the Apache Avro C library.
endef

define Package/avro-c-utils
  SECTIONS:=utils
  CATEGORY:=Utilities
  DEPENDS:=+avro-c
  TITLE:=Apache Avro C utilities
  URL:=https://avro.apache.org
endef

define Package/avro-c-utils/description
  This package contains the Apache Avro C utilities.
endef

TARGET_LDFLAGS += -Wl,--gc-sections

define Package/avro-c/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libavro.so* $(1)/usr/lib/
endef

define Package/avro-c-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/avro* $(1)/usr/bin/
endef

$(eval $(call BuildPackage,avro-c))
$(eval $(call BuildPackage,avro-c-utils))

