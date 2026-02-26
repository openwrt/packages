# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-ack
PKG_VERSION:=3.9.0
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://www.cpan.org/authors/id/P/PE/PETDANCE/
PKG_SOURCE:=ack-v$(PKG_VERSION).tar.gz
PKG_HASH:=94ed477e3b3f94d126cec7329f0e8399f1d0ce82c7c4d882a94adb150e7ffc90

PKG_LICENSE:=Artistic-2.0
PKG_LICENSE_FILE:=LICENSE.md
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/ack-v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/ack
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=A grep-like source code search tool
  URL:=https://beyondgrep.com
  DEPENDS:=+perl +perl-ack
  PROVIDES:=ack-grep
endef

define Package/perl-ack
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=grep-like text finder
  URL:=https://metacpan.org/dist/ack/
  DEPENDS:=perl +perl-file-next +perlbase-filetest +perlbase-if \
    +perlbase-list +perlbase-pod +perlbase-test +perlbase-text \
    +perlbase-term
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/ack/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ack $(1)/usr/bin/
	$(SED) "1"'!'"b;s,^#"'!'".*perl.*,#"'!'"/usr/bin/perl," -i --follow-symlinks $(1)/usr/bin/ack
endef

define Package/perl-ack/install
	$(call perlmod/Install,$(1),App auto/ack)
endef

$(eval $(call BuildPackage,ack))
$(eval $(call BuildPackage,perl-ack))
