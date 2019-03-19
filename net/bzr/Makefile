#
# Copyright (C) 2019 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bzr
PKG_VERSION:=2.7.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://launchpad.net/bzr/2.7/$(PKG_VERSION)/+download
PKG_HASH:=0d451227b705a0dd21d8408353fe7e44d3a5069e6c4c26e5f146f1314b8fdab3

PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING.txt
PKG_CPE_ID:=cpe:/a:canonical:bazaar
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PYTHON_PKG_SETUP_ARGS:=

# If any .pyx files are patched, then this will be required
#HOST_PYTHON_PACKAGE_BUILD_DEPENDS:="Cython>=0.9.6.3"

HOST_BUILD_DEPENDS:=python/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python-package.mk

define Package/bzr
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Version Control Systems
  TITLE:=Easy to use distributed version control system
  URL:=http://bazaar.canonical.com/
  DEPENDS:= \
      +python-light \
      +python-codecs \
      +python-email \
      +python-logging \
      +python-openssl \
      +python-xml \
      +ca-bundle
  VARIANT:=python
endef

define Package/bzr/description
Bazaar (bzr) is a decentralized revision control system, designed to be
easy for developers and end users alike. Bazaar is part of the GNU
project to develop a complete free operating system, and a project of
Canonical.
endef

define PyPackage/bzr/filespec
+|$(PYTHON_PKG_DIR)
-|$(PYTHON_PKG_DIR)/bzrlib/plugins/*/test_*.py
endef

define Host/Compile
	$(call Build/Compile/HostPyMod,,install --prefix="" --root="$(STAGING_DIR_HOSTPKG)")
endef

define Host/Install
	sed -e '1 s|#!.*python.*|#!$(STAGING_DIR_HOSTPKG)/bin/python2|' -i $(STAGING_DIR_HOSTPKG)/bin/bzr
endef

$(eval $(call HostBuild))

$(eval $(call PyPackage,bzr))
$(eval $(call BuildPackage,bzr))
$(eval $(call BuildPackage,bzr-src))
