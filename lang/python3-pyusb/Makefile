#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python3-pyusb
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Heinrich Schuchardt <xypron.glpk@gmx.de>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=pyusb-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/pyusb/PyUSB%201.0/$(PKG_VERSION)
PKG_MD5SUM:=9b173ae33866a2fb4162e0164f01c284

PKG_BUILD_DIR:=$(BUILD_DIR)/pyusb-$(PKG_VERSION)
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python3-package.mk)

define Package/python3-pyusb
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  DEPENDS:= +python3 +libusb-1.0
  TITLE:=PyUSB - Easy USB access on Python
  URL:= http://python3-pyusb.sourceforge.net
endef

define Package/python3-pyusb/description
 PyUSB - Easy USB access on Python
 PyUSB aims to be an easy to use Python module to access USB devices.
 It fails if library libusb-1.0 is built with CONFIG_USE_SSTRIP=y.
endef

define Build/Compile
	$(call Build/Compile/Py3Mod,,install \
	  --prefix="/usr" \
	  --root="$(PKG_INSTALL_DIR)" \
	  )
endef

define Py3Package/python3-pyusb/filespec
+|$(PYTHON3_PKG_DIR)
endef

$(eval $(call Py3Package,python3-pyusb))
$(eval $(call BuildPackage,python3-pyusb))
