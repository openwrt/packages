#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-lxml
PKG_VERSION:=4.4.1
PKG_RELEASE:=1

PKG_SOURCE:=lxml-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/l/lxml
PKG_HASH:=c81cb40bff373ab7a7446d6bbca0190bccc5be3448b47b51d729e37799bb5692

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-lxml-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

PKG_LICENSE:=BSD
PKG_LICENSE_FILES:=LICENSES.txt
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_CPE_ID:=cpe:/a:lxml:lxml

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-lxml/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://lxml.de
  DEPENDS:=+libxml2 +libxslt +libexslt
endef

define Package/python-lxml
$(call Package/python-lxml/Default)
  TITLE:=python-lxml
  DEPENDS+=+PACKAGE_python-lxml:python-light +PACKAGE_python-lxml:python-codecs
  VARIANT:=python
endef

define Package/python3-lxml
$(call Package/python-lxml/Default)
  TITLE:=python3-lxml
  DEPENDS+=+PACKAGE_python3-lxml:python3-light
  VARIANT:=python3
endef

define Package/python-lxml/description
The lxml XML toolkit is a Pythonic binding
for the C libraries libxml2 and libxslt.
endef

define Package/python3-lxml/description
$(call Package/python-lxml/description)
.
(Variant for Python3)
endef

TARGET_LDFLAGS += -lxml2 -lxslt -lexslt

define PyBuild/Compile
	$(call Build/Compile/PyMod,, \
		install --prefix="/usr" --root="$(PKG_INSTALL_DIR)" \
		--static \
		--single-version-externally-managed \
		, \
		INCLUDE="$(STAGING_DIR)/usr/include/ $(STAGING_DIR)/usr/include/libxml2" \
		LIBRARY="$(STAGING_DIR)/usr/lib $(STAGING_DIR)/lib" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
	)
endef

define Py3Build/Compile
	$(call Build/Compile/Py3Mod,, \
		install --prefix="/usr" --root="$(PKG_INSTALL_DIR)" \
		--static \
		--single-version-externally-managed \
		, \
		INCLUDE="$(STAGING_DIR)/usr/include/ $(STAGING_DIR)/usr/include/libxml2" \
		LIBRARY="$(STAGING_DIR)/usr/lib $(STAGING_DIR)/lib" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
	)
endef

$(eval $(call PyPackage,python-lxml))
$(eval $(call BuildPackage,python-lxml))

$(eval $(call Py3Package,python3-lxml))
$(eval $(call BuildPackage,python3-lxml))
