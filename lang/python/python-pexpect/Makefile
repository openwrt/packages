# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pexpect
PKG_VERSION:=4.9.0
PKG_RELEASE:=1

PYPI_NAME:=pexpect
PKG_HASH:=ee7d41123f3c9911050ea2c2dac107568dc43b2d3b0c7557a33212c398ead30f

PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Philip Prindeville <philipp@redfish-solutions.com>, Alexandru Ardelean <alex@shruggie.ro>

PKG_BUILD_DEPENDS:=python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pexpect
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Pexpect is a Pure Python Expect-like module
  URL:=https://github.com/pexpect/pexpect
  DEPENDS:=+python3-light +python3-ptyprocess
endef

define Package/python3-pexpect/description
  Pexpect is a Pure Python Expect-like module

  Pexpect makes Python a better tool for controlling other applications.
endef

$(eval $(call Py3Package,python3-pexpect))
$(eval $(call BuildPackage,python3-pexpect))
$(eval $(call BuildPackage,python3-pexpect-src))
