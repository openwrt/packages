#
# Copyright (C) 2017 Philip Prindeville
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=acpica-unix
PKG_VERSION:=20230331
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_CAT:=gzip -dc
PKG_SOURCE_URL:=https://acpica.org/sites/$(patsubst %-unix,%,$(PKG_NAME))/files/
PKG_HASH:=0c5d695d605aaa61709f3c63f57a1a99b8902291723998446b0813b57ac310e2
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
