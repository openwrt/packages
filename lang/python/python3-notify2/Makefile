include $(TOPDIR)/rules.mk

PKG_NAME:=python3-notify2
PKG_VERSION:=0.3.1
PKG_RELEASE:=$(AUTORELEASE)

PYPI_NAME:=notify2
PKG_HASH:=33fa108d50c42f3cd3407cc437518ad3f6225d1bb237011f16393c9dd3ce197d

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-notify2
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Python interface to DBus notifications
  URL:=https://bitbucket.org/takluyver/pynotify2
  DEPENDS:=+python3 +python3-dbus
endef

define Package/python3-notify2/description
  This is a pure-python replacement for notify-python, using python-dbus to
  communicate with the notifications server directly.
endef

PYTHON3_PKG_SETUP_ARGS=

$(eval $(call Py3Package,python3-notify2))
$(eval $(call BuildPackage,python3-notify2))
$(eval $(call BuildPackage,python3-notify2-src))
