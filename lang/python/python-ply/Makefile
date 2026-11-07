include $(TOPDIR)/rules.mk

PKG_NAME:=python-ply
PKG_VERSION:=3.11
PKG_RELEASE:=1

PYPI_NAME:=ply
PKG_HASH:=00c7c1aaa88358b9c765b6d3000c6eec0ba42abca5351b095321aef446081da3

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=README.md
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:= \
	python3/host \
	python-setuptools/host \
	python-build/host \
	python-installer/host \
	python-wheel/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-ply
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=lex and yacc for Python
  URL:=https://www.dabeaz.com/ply/
  DEPENDS:=+python3-light
  BUILDONLY:=1
endef

define Package/python3-ply/description
  PLY is a 100% Python implementation of the common parsing tools lex and yacc.
endef

$(eval $(call Py3Package,python3-ply))
$(eval $(call BuildPackage,python3-ply))
$(eval $(call BuildPackage,python3-ply-src))
$(eval $(call HostBuild))
