#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-setuptools-rust
PKG_VERSION:=1.7.0
PKG_RELEASE:=1

PYPI_NAME:=setuptools-rust
PKG_HASH:=c7100999948235a38ae7e555fe199aa66c253dc384b125f5d85473bf81eae3a3

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:= \
	python3/host \
	python-build/host \
	python-installer/host \
	python-wheel/host \
	python-setuptools-scm/host \
	python-semantic-version/host \
	python-typing-extensions/host \
	rust/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-setuptools-rust
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Setuptools Rust extension plugin
  URL:=https://github.com/PyO3/setuptools-rust
  DEPENDS:= \
    +python3-light \
    +python3-logging \
    +python3-semantic-version \
    +python3-setuptools \
    +python3-typing-extensions \
    +rust
  BUILDONLY:=1
endef

define Package/python3-setuptools-rust/description
setuptools-rust is a plugin for setuptools to build Rust Python
extensions implemented with PyO3 or rust-cpython.
endef

$(eval $(call Py3Package,python3-setuptools-rust))
$(eval $(call BuildPackage,python3-setuptools-rust))
$(eval $(call BuildPackage,python3-setuptools-rust-src))
$(eval $(call HostBuild))
