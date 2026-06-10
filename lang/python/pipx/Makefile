#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pipx
PKG_VERSION:=1.13.0
PKG_RELEASE:=1

PYPI_NAME:=pipx
PKG_HASH:=d754c19d070893aab5d1ddb3d622ef57ec082b79f53c2664183165dbd2868c0e

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DEPENDS:=python-hatchling/host python-hatch-vcs/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/pipx
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Install/Run Python Applications in Isolated Environments
  URL:=https://pipx.pypa.io/
  DEPENDS:= \
    +python3-light \
    +python3-logging \
    +python3-urllib \
    +python3-venv \
    +python3-argcomplete \
    +python3-packaging \
    +python3-platformdirs \
    +python3-userpath
endef

define Package/pipx/description
pipx is a tool to help you install and run end-user applications written
in Python. It's roughly similar to macOS's brew, JavaScript's npx, and
Linux's apt.

It's closely related to pip. In fact, it uses pip, but is focused on
installing and managing Python packages that can be run from the command
line directly as applications.
endef

$(eval $(call Py3Package,pipx))
$(eval $(call BuildPackage,pipx))
$(eval $(call BuildPackage,pipx-src))
