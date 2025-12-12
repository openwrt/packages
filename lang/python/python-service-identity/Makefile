#
# Copyright (C) 2015, 2018-2020, 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-service-identity
PKG_VERSION:=23.1.0
PKG_RELEASE:=1

PYPI_NAME:=service-identity
PYPI_SOURCE_NAME:=service_identity
PKG_HASH:=ecb33cd96307755041e978ab14f8b14e13b40f1fbd525a4dc78f46d2b986431d

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_BUILD_DEPENDS:=python-hatchling/host python-hatch-vcs/host python-hatch-fancy-pypi-readme/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-service-identity
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Service identity verification
  URL:=https://service-identity.readthedocs.io/
  DEPENDS:= \
      +python3-light \
      +python3-attrs \
      +python3-cryptography \
      +python3-pyasn1 \
      +python3-pyasn1-modules
endef

define Package/python3-service-identity/description
service_identity aspires to give you all the tools you need for
verifying whether a certificate is valid for the intended purposes.
endef

$(eval $(call Py3Package,python3-service-identity))
$(eval $(call BuildPackage,python3-service-identity))
$(eval $(call BuildPackage,python3-service-identity-src))
