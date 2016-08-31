#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python-dev
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) development files
  DEPENDS:=+python
endef

define PyPackage/python-dev/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/python*config $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpython$(PYTHON_VERSION).so* $(1)/usr/lib
endef

$(eval $(call PyBasePackage,python-dev, \
	/usr/lib/python$(PYTHON_VERSION)/config \
	/usr/include/python$(PYTHON_VERSION) \
	/usr/lib/pkgconfig \
	, \
	DO_NOT_ADD_TO_PACKAGE_DEPENDS \
))

