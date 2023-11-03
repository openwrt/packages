#
# Copyright (C) 2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-typing-extensions
PKG_VERSION:=4.8.0
PKG_RELEASE:=1

PYPI_NAME:=typing-extensions
PYPI_SOURCE_NAME:=typing_extensions
PKG_HASH:=df8e4339e9cb77357558cbdbceca33c303714cf861d1eef15e1070055ae8b7ef

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>, Jeffery To <jeffery.to@gmail.com>
PKG_LICENSE:=Python-2.0.1 0BSD
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python-flit-core/host
HOST_BUILD_DEPENDS:=python3/host python-build/host python-installer/host python-flit-core/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-typing-extensions
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Backported and Experimental Type Hints
  URL:=https://github.com/python/typing_extensions
  DEPENDS:=+python3-light
endef

define Package/python3-typing-extensions/description
The typing_extensions module serves two related purposes:

* Enable use of new type system features on older Python versions. For
  example, typing.TypeGuard is new in Python 3.10, but typing_extensions
  allows users on previous Python versions to use it too.

* Enable experimentation with new type system PEPs before they are
  accepted and added to the typing module.
endef

$(eval $(call Py3Package,python3-typing-extensions))
$(eval $(call BuildPackage,python3-typing-extensions))
$(eval $(call BuildPackage,python3-typing-extensions-src))
$(eval $(call HostBuild))
