include $(TOPDIR)/rules.mk

PKG_NAME:=python-zope-event
PKG_VERSION:=6.1
PKG_RELEASE:=1

PYPI_NAME:=zope.event
PYPI_SOURCE_NAME:=zope_event
PKG_HASH:=6052a3e0cb8565d3d4ef1a3a7809336ac519bc4fe38398cb8d466db09adef4f0

PKG_BUILD_DEPENDS:=python3/host python-setuptools

PKG_LICENSE:=ZPL-2.1
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Andy Syam <privasisource@gmail.com>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-zope-event
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Very basic event publishing system
  URL:=https://github.com/zopefoundation/zope.event
  DEPENDS:=+python3-light +python3-logging
endef

define Package/python3-zope-event/description
The zope.event package provides a simple event system, including:
An event publishing API, intended for use by applications which are unaware of any subscribers to their events.
A very simple synchronous event-dispatching system, on which more sophisticated event dispatching systems can be built. For example, a type-based event dispatching system that builds on zope.event can be found in zope.component.
endef

$(eval $(call Py3Package,python3-zope-event))
$(eval $(call BuildPackage,python3-zope-event))
$(eval $(call BuildPackage,python3-zope-event-src))
