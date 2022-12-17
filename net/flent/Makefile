include $(TOPDIR)/rules.mk

PKG_NAME:=flent
PKG_VERSION:=2.1.1
PKG_RELEASE:=1

PYPI_NAME:=flent
PKG_HASH:=db581deac3d8099965dd0d8eee4b9c4d1857bdce5bc97790af9d3ed5b6554f73

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

include ../../lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

define Package/flent
  SECTION:=net
  CATEGORY:=Network
  TITLE:=The FLExible Network Tester
  URL:=https://flent.org
  CONFLICTS:=python3-flent
  DEPENDS:= \
    +python3-light \
    +python3-uuid \
    +python3-logging \
    +python3-distutils \
    +python3-defusedxml \
    +netperf \
    +fping
endef

define Package/flent/description
  Flent is a Python wrapper to run multiple simultaneous
  netperf/iperf/ping instances and aggregate the results.
endef

$(eval $(call Py3Package,flent))
$(eval $(call BuildPackage,flent))
$(eval $(call BuildPackage,flent-src))
