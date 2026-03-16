#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=semodule-utils
PKG_VERSION:=3.9
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/SELinuxProject/selinux/releases/download/$(PKG_VERSION)
PKG_HASH:=729be36e4726c5d0833732681a94b2e0e4aff973c076504e41f8547abb6c5424

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/semodule-utils/Default
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libsepol
  TITLE:=SELinux policy module utility
  URL:=http://selinuxproject.org/page/Main_Page
endef

define Package/semodule-utils/Default/description
semodule-utils is a collection of utilities for dealing with policy
modules.
endef

define Package/semodule-utils
$(call Package/semodule-utils/Default)
  TITLE+= meta-package
  DEPENDS:= \
    semodule-expand \
    semodule-link \
    semodule-package \
    semodule-unpackage
endef

define Package/semodule-utils/description
$(call Package/semodule-utils/Default/description)

This is a meta-package that installs all of the semodule-utils tools.
endef

Package/semodule-utils/install:=:

define BuildUtil
  define Package/semodule-$(1)
  $(call Package/semodule-utils/Default)
    TITLE+= semodule_$(1)
  endef

  define Package/semodule-$(1)/description
$(call Package/semodule-utils/Default/description)

This contains the semodule_$(1) tool.
  endef

  define Package/semodule-$(1)/install
	$$(INSTALL_DIR) $$(1)/usr/bin
	$$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/bin/semodule_$(1) $$(1)/usr/bin/
  endef

  $$(eval $$(call BuildPackage,semodule-$(1)))
endef

$(eval $(call BuildPackage,semodule-utils))

$(eval $(call BuildUtil,expand))
$(eval $(call BuildUtil,link))
$(eval $(call BuildUtil,package))
$(eval $(call BuildUtil,unpackage))
