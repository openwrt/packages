#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=setools
PKG_VERSION:=4.4.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/SELinuxProject/setools/releases/download/$(PKG_VERSION)
PKG_HASH:=2f751599dbed0d628fb268a3302dd8c578829f302bd28e8c08e182aef7fd5cb8

PKG_BUILD_DEPENDS:=python-cython/host # Cython>=0.27

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=GPL-2.0-only LGPL-2.1-only
PKG_LICENSE_FILES:=COPYING COPYING.GPL COPYING.LGPL
PKG_CPE_ID:=cpe:/a:selinuxproject:setools

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

TAR_OPTIONS+= --strip-components 1
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)

define Package/setools/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=SELinux policy analysis tool
  URL:=http://selinuxproject.org/page/Main_Page
  DEPENDS:=+python3-light +python3-logging +python3-setools
endef

define Package/setools/Default/description
SETools is a collection of tools and libraries designed to facilitate
SELinux policy analysis.
endef

define Package/python3-setools
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=SETools Python bindings
  URL:=http://selinuxproject.org/page/Main_Page
  DEPENDS:=+python3-light +python3-logging +python3-pkg-resources +libselinux +libsepol
endef

define Package/python3-setools/description
$(call Package/setools/Default/description)

This contains the SETools Python binding.
endef

Py3Package/python3-setools/install:=:

define Package/setools
$(call Package/setools/Default)
  TITLE+= meta-package
  DEPENDS:= \
    setools-sechecker \
    setools-sediff \
    setools-sedta \
    setools-seinfo \
    setools-seinfoflow \
    setools-sesearch
endef

define Package/setools/description
$(call Package/setools/Default/description)

This is a meta-package that installs all of the SETools tools.
endef

Package/setools/install:=:

define BuildUtil
  define Package/setools-$(1)
  $(call Package/setools/Default)
    TITLE+= $(1)
    DEPENDS+= $(2)
  endef

  define Package/setools-$(1)/description
$(call Package/setools/Default/description)

This contains the $(1) tool.
  endef

  define Py3Package/setools-$(1)/install
	$$(INSTALL_DIR) $$(1)/usr/bin
	$$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/bin/$(1) $$(1)/usr/bin/
  endef

  Py3Package/setools-$(1)/filespec:=

  $$(eval $$(call Py3Package,setools-$(1)))
  $$(eval $$(call BuildPackage,setools-$(1)))
endef

$(eval $(call Py3Package,python3-setools))
$(eval $(call BuildPackage,python3-setools))
$(eval $(call BuildPackage,python3-setools-src))

$(eval $(call BuildPackage,setools))

$(eval $(call BuildUtil,sechecker))
$(eval $(call BuildUtil,sediff))
$(eval $(call BuildUtil,sedta,+python3-networkx))
$(eval $(call BuildUtil,seinfo))
$(eval $(call BuildUtil,seinfoflow,+python3-networkx))
$(eval $(call BuildUtil,sesearch))
