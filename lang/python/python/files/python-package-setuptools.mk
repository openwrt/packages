#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python-setuptools
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) setuptools module
  VERSION:=$(PYTHON_SETUPTOOLS_VERSION)-$(PYTHON_SETUPTOOLS_PKG_RELEASE)
  LICENSE:=MIT
  LICENSE_FILES:=LICENSE
#  CPE_ID:=cpe:/a:python:setuptools # not currently handled this way by uscan
  DEPENDS:=+python +python-pkg-resources
endef

define PyPackage/python-setuptools/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/python$(PYTHON_VERSION)/site-packages
	$(CP) $(PKG_BUILD_DIR)/install-setuptools/usr/bin/* $(1)/usr/bin
	$(CP) \
		$(PKG_BUILD_DIR)/install-setuptools/usr/lib/python$(PYTHON_VERSION)/site-packages/setuptools \
		$(PKG_BUILD_DIR)/install-setuptools/usr/lib/python$(PYTHON_VERSION)/site-packages/setuptools-$(PYTHON_SETUPTOOLS_VERSION).dist-info \
		$(PKG_BUILD_DIR)/install-setuptools/usr/lib/python$(PYTHON_VERSION)/site-packages/easy_install.py \
		$(1)/usr/lib/python$(PYTHON_VERSION)/site-packages
	$(CP) \
		$(1)/usr/lib/python$(PYTHON_VERSION)/site-packages/setuptools/site-patch.py \
		$(1)/usr/lib/python$(PYTHON_VERSION)/site-packages/setuptools/site-patch.py.txt
endef

$(eval $(call PyBasePackage,python-setuptools, \
	, \
	DO_NOT_ADD_TO_PACKAGE_DEPENDS \
))
