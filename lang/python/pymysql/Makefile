#
# Copyright (C) Alexandru Ardelean <ardeleanalex@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pymysql
PKG_VERSION:=1.0.2
PKG_RELEASE:=2

PYPI_NAME:=PyMySQL
PKG_HASH:=816927a350f38d56072aeca5dfb10221fe1dc653745853d30a216637f5d7ad36

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_CONFIG_DEPENDS:=CONFIG_PYTHON3_PYMYSQL_SHA_PASSWORD_SUPPORT

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pymysql/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Pure Python MySQL Client
  URL:=https://pymysql.readthedocs.io/
endef

define Package/python3-pymysql
$(call Package/python3-pymysql/Default)
  DEPENDS:=+python3
endef

define Package/python3-pymysql/description
  This package contains a pure-Python MySQL client library, based on PEP 249.
endef

define Package/python3-pymysql-sha-pwd
$(call Package/python3-pymysql/Default)
  TITLE+=w/ SHA256 password auth
  DEPENDS:=+python3-pymysql $(RUST_ARCH_DEPENDS) +PACKAGE_python3-pymysql-sha-pwd:python3-cryptography
endef

define Package/python3-pymysql-sha-pwd/description
  This is a meta-package installing python3-pymysql and python3-cryptography
  packages to be able to use pymysql with “sha256_password” or
  “caching_sha2_password” for authentication.
endef

define Package/python3-pymysql-sha-pwd/install
  true
endef

$(eval $(call Py3Package,python3-pymysql))
$(eval $(call BuildPackage,python3-pymysql))
$(eval $(call BuildPackage,python3-pymysql-src))
$(eval $(call BuildPackage,python3-pymysql-sha-pwd))
