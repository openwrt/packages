include $(TOPDIR)/rules.mk

PKG_NAME:=python3-iperf3
PKG_VERSION:=0.1.11
PKG_RELEASE:=1

PYPI_NAME:=iperf3
PKG_HASH:=d50eebbf2dcf445a173f98a82f9c433e0302d3dfb7987e1f21b86b35ef63ce26

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-iperf3
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python wrapper around iperf3.
  URL:=https://github.com/thiezn/iperf3-python
  DEPENDS:=+python3-light +python3-ctypes +libiperf3
endef

define Package/python3-iperf3/description
  iperf3 for python provides a wrapper around the iperf3 utility.
endef

$(eval $(call Py3Package,python3-iperf3))
$(eval $(call BuildPackage,python3-iperf3))
$(eval $(call BuildPackage,python3-iperf3-src))
