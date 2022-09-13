include $(TOPDIR)/rules.mk

PKG_NAME:=python3-flent
PKG_VERSION:=2.0.1
PKG_RELEASE:=$(AUTORELEASE)

PYPI_NAME:=flent
PKG_HASH:=300a09938dc2b4a0463c9144626f25e0bd736fd47806a9444719fa024d671796

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-flent
  SECTION:=lang-python
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=The FLExible Network Tester
  URL:=https://github.com/tohojo/flent
  DEPENDS:= \
    +python3-light \
    +python3-email \
    +python3-urllib \
    +python3-uuid \
    +python3-logging \
    +python3-xml \
    +python3-decimal \
    +python3-distutils \
    +netperf \
    +fping
endef

define Package/python3-flent/description
  Flent is a Python wrapper to run multiple simultaneous
  netperf/iperf/ping instances and aggregate the results.
endef

$(eval $(call Py3Package,python3-flent))
$(eval $(call BuildPackage,python3-flent))
$(eval $(call BuildPackage,python3-flent-src))
