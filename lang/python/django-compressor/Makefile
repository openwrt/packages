#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-compressor
PKG_VERSION:=2.2
PKG_RELEASE:=3

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=django_compressor-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/82/76/1355459f90714517c52f264aa7245b52e59a273ec16e8f8d505fa6c342f8/
PKG_HASH:=9616570e5b08e92fa9eadc7a1b1b49639cce07ef392fc27c74230ab08075b30f

PKG_BUILD_DIR:=$(BUILD_DIR)/django_compressor-$(PKG_VERSION)/

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/django-compressor
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Compress CSS/JS into single cached files
  URL:=http://django-compressor.readthedocs.org/
  DEPENDS:=+python +django +django-appconf +python-rcssmin
  VARIANT:=python
endef

define Package/django-compressor/description
  Compresses linked and inline JavaScript or CSS into single cached files.
  Note that the JavaScript filter is not being installed as a dependency.
  You'll need to build the rjsmin module (it is not par of the openwrt standard
  feeds) to use JavaScript functionality.
endef

$(eval $(call PyPackage,django-compressor))
$(eval $(call BuildPackage,django-compressor))
$(eval $(call BuildPackage,django-compressor-src))
