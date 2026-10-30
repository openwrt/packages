#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-bcrypt
PKG_VERSION:=5.0.0
PKG_RELEASE:=2

PYPI_NAME:=bcrypt
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-vendor.tar.zst
PKG_SOURCE_URL:=@OPENWRT
PKG_SOURCE_PROTO:=cargo-vendor-archive
PKG_VENDOR_FILE:=$(PYPI_NAME)-$(PKG_VERSION).tar.gz
PKG_VENDOR_URL:=https://files.pythonhosted.org/packages/source/b/$(PYPI_NAME)
PKG_VENDOR_SUBDIR:=src/_bcrypt
PKG_VENDOR_HASH:=f748f7c2d6fd375cc93d3fba7ef4a9e3a092421b8dbf34d8d4dc06be9492dfdd
PKG_HASH:=a7197d753cafef65a09eb8c47c1fc6c01345de33d6f8fa5bf870cb52043ff8ae

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DEPENDS:=python-setuptools-rust/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk
include $(INCLUDE_DIR)/rust-values.mk

PKG_BUILD_DEPENDS+=$(RUST_PKG_BUILD_DEPENDS)
PKG_CONFIG_DEPENDS+=$(RUST_PKG_CONFIG_DEPENDS)

# setuptools-rust sets RUSTFLAGS for musl, which replaces the target
# rustflags; it keeps those given in RUSTFLAGS.
PYTHON3_PKG_BUILD_VARS+=RUSTFLAGS="$(CARGO_RUSTFLAGS)"

define Package/python3-bcrypt
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Modern password hashing
  URL:=https://github.com/pyca/bcrypt/
  DEPENDS:=+python3-light $(RUST_PKG_DEPENDS)
endef

define Package/python3-bcrypt/description
Acceptable password hashing for your software and your servers (but you
should really use argon2id or scrypt)
endef

$(eval $(call Py3Package,python3-bcrypt))
$(eval $(call BuildPackage,python3-bcrypt))
$(eval $(call BuildPackage,python3-bcrypt-src))
