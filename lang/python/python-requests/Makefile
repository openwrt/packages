#
# Copyright (C) 2019 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-requests
PKG_VERSION:=2.22.0
PKG_RELEASE:=1

PKG_SOURCE:=requests-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/01/62/ddcf76d1d19885e8579acb1b1df26a852b03472c0e46d2b959a714c90608/
PKG_HASH:=11e007a8a2aa0323f5a921e9e6a2d7e4e67d9877e85773fba9ba6419025cbeb4

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-requests-$(PKG_VERSION)

PKG_LICENSE:=BSD License
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-requests/Default
  SECTION:=lang-python
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=http://python-requests.org
endef

define Package/python-requests
$(call Package/python-requests/Default)
  TITLE:=python-requests
  DEPENDS:= \
      +python-light \
      +python-urllib3 \
      +python-chardet \
      +python-certifi \
      +python-idna
  VARIANT:=python
endef

define Package/python3-requests
$(call Package/python-requests/Default)
  TITLE:=python3-requests
  DEPENDS:= \
      +python3-light \
      +python3-urllib3 \
      +python3-chardet \
      +python3-certifi \
      +python3-idna
  VARIANT:=python3
endef

define Package/python-requests/description
Requests is the only Non-GMO HTTP library for Python, safe for human consumption.
endef

define Package/python3-requests/description
$(call Package/python-requests/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-requests))
$(eval $(call BuildPackage,python-requests))
$(eval $(call BuildPackage,python-requests-src))

$(eval $(call Py3Package,python3-requests))
$(eval $(call BuildPackage,python3-requests))
$(eval $(call BuildPackage,python3-requests-src))
