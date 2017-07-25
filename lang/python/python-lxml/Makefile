#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-lxml
PKG_VERSION:=3.7.2
PKG_RELEASE:=1

PKG_SOURCE:=lxml-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=http://lxml.de/files/
PKG_HASH:=59d9176360dbc3919e9d4bfca85c1ca64ab4f4ee00e6f119d7150ba887e3410a

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-lxml-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

PKG_LICENSE:=BSD
PKG_LICENSE_FILES:=LICENSES.txt
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)
$(call include_mk, python3-package.mk)

define Package/python-lxml/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=http://lxml.de
  DEPENDS:=+libxml2 +libxslt +libexslt
endef

define Package/python-lxml
$(call Package/python-lxml/Default)
  TITLE:=python-lxml
<<<<<<< HEAD
  DEPENDS+=+python-light +python-codecs
=======
  DEPENDS+=+PACKAGE_python-lxml:python-light +PACKAGE_python-lxml:python-codecs
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
  VARIANT:=python
endef

define Package/python3-lxml
$(call Package/python-lxml/Default)
  TITLE:=python3-lxml
<<<<<<< HEAD
  DEPENDS+=+python3-light
=======
  DEPENDS+=+PACKAGE_python3-lxml:python3-light
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
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

<<<<<<< HEAD
define PyBuild/Compile/Default
=======
define PyBuild/Compile
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
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

<<<<<<< HEAD
define Py3Build/Compile/Default
=======
define Py3Build/Compile
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
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
