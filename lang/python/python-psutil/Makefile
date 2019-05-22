#
# Copyright (C) 2019 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-psutil
PKG_VERSION:=5.6.2
PKG_RELEASE:=1

PKG_SOURCE:=psutil-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/c6/c1/beed5e4eaa1345901b595048fab1c85aee647ea0fc02d9e8bf9aceb81078/
PKG_HASH:=828e1c3ca6756c54ac00f1427fdac8b12e21b8a068c3bb9b631a1734cada25ed

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-psutil-$(PKG_VERSION)

PKG_LICENSE:=BSD License
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-psutil/Default
  SECTION:=lang-python
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=http://www.pycrypto.org/
endef

define Package/python-psutil
$(call Package/python-psutil/Default)
  TITLE:=python-psutil
  DEPENDS:=+PACKAGE_python-psutil:python-light
  VARIANT:=python
endef

define Package/python3-psutil
$(call Package/python-psutil/Default)
  TITLE:=python3-psutil
  DEPENDS:=+PACKAGE_python3-psutil:python3-light
  VARIANT:=python3
endef

define Package/python-psutil/description
psutil (process and system utilities) is a cross-platform library
for retrieving information on running processes and system
utilization (CPU, memory, disks, network, sensors) in Python.
endef

define Package/python3-psutil/description
$(call Package/python-psutil/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-psutil))
$(eval $(call BuildPackage,python-psutil))
$(eval $(call BuildPackage,python-psutil-src))

$(eval $(call Py3Package,python3-psutil))
$(eval $(call BuildPackage,python3-psutil))
$(eval $(call BuildPackage,python3-psutil-src))
