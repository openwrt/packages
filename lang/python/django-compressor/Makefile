#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-compressor
PKG_VERSION:=2.2
PKG_RELEASE:=8

PYPI_NAME:=$(PKG_NAME)
PYPI_SOURCE_NAME:=django_compressor
PKG_HASH:=9616570e5b08e92fa9eadc7a1b1b49639cce07ef392fc27c74230ab08075b30f

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-django-compressor
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Compress CSS/JS into single cached files
  URL:=https://django-compressor.readthedocs.io
  DEPENDS:= \
	+python3 \
	+python3-django1 \
	+python3-django-appconf \
	+python3-rcssmin
endef

define Package/python3-django-compressor/description
  Compresses linked and inline JavaScript or CSS into single cached files.
  Note that the JavaScript filter is not being installed as a dependency.
  You'll need to build the rjsmin module (it is not par of the openwrt standard
  feeds) to use JavaScript functionality.
endef

$(eval $(call Py3Package,python3-django-compressor))
$(eval $(call BuildPackage,python3-django-compressor))
$(eval $(call BuildPackage,python3-django-compressor-src))
