#
# Copyright (C) 2017 Philip Prindeville
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=acpica-unix
PKG_VERSION:=20221020
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar_0.gz
PKG_CAT:=gzip -dc
PKG_SOURCE_URL:=https://acpica.org/sites/$(patsubst %-unix,%,$(PKG_NAME))/files/
PKG_HASH:=33a2e394aca0ca57d4018afe3da340dfad5eb45b1b9300e81dd595fda07cf1c5
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
