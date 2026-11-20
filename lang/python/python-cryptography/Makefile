#
# Copyright (C) 2015-2016, 2018-2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-cryptography
PKG_VERSION:=50.0.2
PKG_RELEASE:=2

PYPI_NAME:=cryptography
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-vendor.tar.zst
PKG_SOURCE_URL:=@OPENWRT
PKG_SOURCE_PROTO:=cargo-vendor-archive
PKG_VENDOR_FILE:=$(PYPI_NAME)-$(PKG_VERSION).tar.gz
PKG_VENDOR_URL:=https://files.pythonhosted.org/packages/source/c/$(PYPI_NAME)
PKG_VENDOR_HASH:=7b46165bb56eb4704e2eaaf86f3c940d19154535d9b0ca7d6d590b04060e00d5
PKG_HASH:=9a20f99850bc1b0aa46e39e894585e646c9a69f2c98e3dc5c81caacf55d6940a

PKG_LICENSE:=Apache-2.0 BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.APACHE LICENSE.BSD
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_CPE_ID:=cpe:/a:cryptography.io:cryptography

PKG_BUILD_DEPENDS:=libffi/host python-cffi/host python-maturin/host python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk
include $(INCLUDE_DIR)/rust-values.mk

PKG_BUILD_DEPENDS+=$(RUST_PKG_BUILD_DEPENDS)
PKG_CONFIG_DEPENDS+=$(RUST_PKG_CONFIG_DEPENDS)

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
      +python3-urllib \
      +python3-cffi \
      $(RUST_PKG_DEPENDS)
endef

define Package/python3-cryptography/description
cryptography is a package which provides cryptographic recipes and
primitives to Python developers. Our goal is for it to be your
"cryptographic standard library".
endef

$(eval $(call Py3Package,python3-cryptography))
$(eval $(call BuildPackage,python3-cryptography))
$(eval $(call BuildPackage,python3-cryptography-src))
