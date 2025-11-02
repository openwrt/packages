#
# Copyright (C) 2015-2016, 2018-2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-cryptography
PKG_VERSION:=46.0.3
PKG_RELEASE:=1

PYPI_NAME:=cryptography
PKG_HASH:=a8b17438104fed022ce745b362294d9ce35b4c2e45c1d958ad4a4b019285f4a1

PKG_LICENSE:=Apache-2.0 BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.APACHE LICENSE.BSD
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>
PKG_CPE_ID:=cpe:/a:cryptography.io:cryptography

PKG_BUILD_DEPENDS:=libffi/host python-cffi/host python-maturin/host python-setuptools-rust/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-cryptography
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Cryptographic recipes and primitives
  URL:=https://github.com/pyca/cryptography
  DEPENDS:= \
      +libopenssl \
      +libopenssl-legacy \
      +python3-light \
      +python3-email \
      +python3-urllib \
      +python3-cffi \
      $(RUST_ARCH_DEPENDS)
endef

define Package/python3-cryptography/description
cryptography is a package which provides cryptographic recipes and
primitives to Python developers. Our goal is for it to be your
"cryptographic standard library".
endef

$(eval $(call Py3Package,python3-cryptography))
$(eval $(call BuildPackage,python3-cryptography))
$(eval $(call BuildPackage,python3-cryptography-src))
