#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-hatch-fancy-pypi-readme
PKG_VERSION:=23.1.0
PKG_RELEASE:=1

PYPI_NAME:=hatch-fancy-pypi-readme
PYPI_SOURCE_NAME:=hatch_fancy_pypi_readme
PKG_HASH:=b1df44063094af1e8248ceacd47a92c9cf313d6b9823bf66af8a927c3960287d

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:=python3/host python-build/host python-installer/host python-hatchling/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-hatch-fancy-pypi-readme
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Fancy PyPI READMEs with Hatch
  URL:=https://github.com/hynek/hatch-fancy-pypi-readme
  DEPENDS:=+python3-light +python3-hatchling
  BUILDONLY:=1
endef

define Package/python3-hatch-fancy-pypi-readme/description
hatch-fancy-pypi-readme is a Hatch metadata plugin for everyone who
cares about the first impression of their project’s PyPI landing page.
It allows you to define your PyPI project description in terms of
concatenated fragments that are based on static strings, files, and most
importantly: parts of files defined using cut-off points or regular
expressions.

Once you’ve assembled your readme, you can additionally run regular
expression-based substitutions over it. For instance to make relative
links absolute or to linkify users and issue numbers in your changelog.
endef

$(eval $(call Py3Package,python3-hatch-fancy-pypi-readme))
$(eval $(call BuildPackage,python3-hatch-fancy-pypi-readme))
$(eval $(call BuildPackage,python3-hatch-fancy-pypi-readme-src))
$(eval $(call HostBuild))
