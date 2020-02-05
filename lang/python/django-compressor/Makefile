#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-compressor
PKG_VERSION:=2.2
PKG_RELEASE:=7

PYPI_NAME:=$(PKG_NAME)
PYPI_SOURCE_NAME:=django_compressor
PKG_HASH:=9616570e5b08e92fa9eadc7a1b1b49639cce07ef392fc27c74230ab08075b30f

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/django-compressor/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Compress CSS/JS into single cached files
  URL:=https://django-compressor.readthedocs.io
endef

define Package/python-django-compressor
$(call Package/django-compressor/Default)
  DEPENDS:= \
	+PACKAGE_python-django-compressor:python \
	python-django1 \
	+PACKAGE_python-django-compressor:python-django-appconf \
	+PACKAGE_python-django-compressor:python-rcssmin
  VARIANT:=python
  MDEPENDS:=python-django1
endef

define Package/python-django-compressor/description
  Compresses linked and inline JavaScript or CSS into single cached files.
  Note that the JavaScript filter is not being installed as a dependency.
  You'll need to build the rjsmin module (it is not par of the openwrt standard
  feeds) to use JavaScript functionality.
endef

define Package/python3-django-compressor
$(call Package/django-compressor/Default)
  DEPENDS:= \
	+PACKAGE_python3-django-compressor:python3 \
	+PACKAGE_python3-django-compressor:python3-django1 \
	+PACKAGE_python3-django-compressor:python3-django-appconf \
	+PACKAGE_python3-django-compressor:python3-rcssmin
  VARIANT:=python3
endef

define Package/python3-django-compressor/description
$(call Package/python-django-compressor/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-django-compressor))
$(eval $(call BuildPackage,python-django-compressor))
$(eval $(call BuildPackage,python-django-compressor-src))

$(eval $(call Py3Package,python3-django-compressor))
$(eval $(call BuildPackage,python3-django-compressor))
$(eval $(call BuildPackage,python3-django-compressor-src))
