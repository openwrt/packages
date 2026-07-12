# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=python-ptyprocess
PKG_VERSION:=0.7.0
PKG_RELEASE:=1

PYPI_NAME:=ptyprocess
PKG_HASH:=5c5d0a3b48ceee0b48485e0c26037c0acd7d29765ca3fbb5cb3831d347423220

PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Philip Prindeville <philipp@redfish-solutions.com>, Alexandru Ardelean <alex@shruggie.ro>

PKG_BUILD_DEPENDS:=python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-ptyprocess
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Launch a subprocess in a pseudo terminal (pty), and interact with both the process and its pty.
  URL:=https://github.com/pexpect/ptyprocess
  DEPENDS:=+python3-light
endef

define Package/python3-ptyprocess/description
  Launch a subprocess in a pseudo terminal (pty), and interact with both the process and its pty.
endef

$(eval $(call Py3Package,python3-ptyprocess))
$(eval $(call BuildPackage,python3-ptyprocess))
$(eval $(call BuildPackage,python3-ptyprocess-src))
