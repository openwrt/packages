#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-compressor
PKG_VERSION:=2.2
PKG_RELEASE:=5

PKG_SOURCE:=django_compressor-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/d/$(PKG_NAME)/
PKG_HASH:=9616570e5b08e92fa9eadc7a1b1b49639cce07ef392fc27c74230ab08075b30f

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/$(PKG_NAME)/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Compress CSS/JS into single cached files
  URL:=https://$(PKG_NAME).readthedocs.io
endef

define Package/python-$(PKG_NAME)
$(call Package/$(PKG_NAME)/Default)
  DEPENDS:= \
	+PACKAGE_python-$(PKG_NAME):python \
	python-django \
	+PACKAGE_python-$(PKG_NAME):python-django-appconf \
	+PACKAGE_python-$(PKG_NAME):python-rcssmin
  VARIANT:=python
  MDEPENDS:=python-django
endef

define Package/python-$(PKG_NAME)/description
  Compresses linked and inline JavaScript or CSS into single cached files.
  Note that the JavaScript filter is not being installed as a dependency.
  You'll need to build the rjsmin module (it is not par of the openwrt standard
  feeds) to use JavaScript functionality.
endef

define Package/python3-$(PKG_NAME)
$(call Package/$(PKG_NAME)/Default)
  DEPENDS:= \
	+PACKAGE_python3-$(PKG_NAME):python3 \
	python3-django \
	+PACKAGE_python3-$(PKG_NAME):python3-django-appconf \
	+PACKAGE_python3-$(PKG_NAME):python3-rcssmin
  VARIANT:=python3
  MDEPENDS:=python3-django
endef

define Package/python3-$(PKG_NAME)/description
$(call define Package/python-$(PKG_NAME)/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-$(PKG_NAME)))
$(eval $(call BuildPackage,python-$(PKG_NAME)))
$(eval $(call BuildPackage,python-$(PKG_NAME)-src))

$(eval $(call Py3Package,python3-$(PKG_NAME)))
$(eval $(call BuildPackage,python3-$(PKG_NAME)))
$(eval $(call BuildPackage,python3-$(PKG_NAME)-src))
