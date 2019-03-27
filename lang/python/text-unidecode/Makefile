#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-text-unidecode
PKG_VERSION:=1.2
PKG_RELEASE:=1

PKG_SOURCE:=text-unidecode-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/t/text-unidecode/
PKG_HASH:=5a1375bb2ba7968740508ae38d92e1f889a0832913cb1c447d5e2046061a396d

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-text-unidecode-$(PKG_VERSION)

PKG_LICENSE:=Artistic-1.0-cl8
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-text-unidecode/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=The most basic Text::Unidecode port
  URL:=https://github.com/kmike/text-unidecode/
endef

define Package/python-text-unidecode
$(call Package/python-text-unidecode/Default)
  DEPENDS:= \
      +PACKAGE_python-text-unidecode:python-light
  VARIANT:=python
endef

define Package/python3-text-unidecode
$(call Package/python-text-unidecode/Default)
  DEPENDS:= \
      +PACKAGE_python3-text-unidecode:python3-light
  VARIANT:=python3
endef

define Package/python-text-unidecode/description
text-unidecode is the most basic port of the Text::Unidecode Perl library.
endef

define Package/python3-text-unidecode/description
$(call Package/python-text-unidecode/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-text-unidecode))
$(eval $(call BuildPackage,python-text-unidecode))
$(eval $(call BuildPackage,python-text-unidecode-src))

$(eval $(call Py3Package,python3-text-unidecode))
$(eval $(call BuildPackage,python3-text-unidecode))
$(eval $(call BuildPackage,python3-text-unidecode-src))
