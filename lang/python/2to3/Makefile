#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=2to3
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Gerald Kerma <gandalf@gk2.net>,Jeffery To <jeffery.to@gmail.com>
PKG_LICENSE:=PSF-2.0
PKG_LICENSE_FILES:=copyright

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:=python3/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/2to3
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=2to3 binary using python3
  URL:=https://salsa.debian.org/cpython-team/python3-defaults
  BUILDONLY:=1
endef

define Package/2to3/description
  2to3 is a Python program that reads Python 2.x source code and applies a
  series of fixers to transform it into valid Python 3.x code. The standard
  library contains a rich set of fixers that will handle almost all code. 2to3
  supporting library lib2to3 is, however, a flexible and generic library, so it
  is possible to write your own fixers for 2to3. lib2to3 could also be adapted
  to custom applications in which Python code needs to be edited automatically.
endef

define Host/Install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) ./files/2to3.py $(1)/bin/2to3
	$(SED) '1c#!$(STAGING_DIR_HOSTPKG)/bin/python3' $(1)/bin/2to3
endef

define Host/Clean
	rm -f $(STAGING_DIR_HOSTPKG)/bin/2to3
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,2to3))
