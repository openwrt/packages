#
# Copyright (C) 2017 Philip Prindeville
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=acpica-unix
PKG_VERSION:=20211217
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://acpica.org/sites/$(patsubst %-unix,%,$(PKG_NAME))/files/$(PKG_SOURCE_URL)
PKG_HASH:=2511f85828820d747fa3e2c3433d3a38c22db3d9c2fd900e1a84eb4173cb5992
PKG_MAINTAINER:=Philip Prindeville <philipp@redfish-solutions.com>

PKG_LICENSE:=GPL-2.0

PKG_FORTIFY_SOURCE:=0
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/acpica-unix
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=@TARGET_x86_64
  TITLE:=ACPI utilities (currently acpidump) for UNIX
  URL:=https://acpica.org/
endef

define Package/acpica-unix/description
	Open Source utilities for ACPI including the ACPICA Machine Language
	(AML) interpreter, a simulator, test suites, and a compiler to
	translate ACPI Source Language (ASL) into AML.

	At this time, only acpidump is bundled; more might be added later.
endef

define Build/Configure
endef

MAKE_VARS += HOST=_LINUX

MAKE_PATH:=generate/unix

define Package/acpica-unix/install
	$(INSTALL_DIR) $(1)/usr/bin

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/generate/unix/bin/* \
		$(1)/usr/bin/
endef

$(eval $(call BuildPackage,acpica-unix))
