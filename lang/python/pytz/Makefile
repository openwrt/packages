#
# Copyright (C) 2007-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pytz
PKG_VERSION:=2018.9
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/pytz
PKG_HASH:=d5f05e487007e29e03409f9398d074e158d920d36eb82eaf66fb1136b0c5374c

PKG_BUILD_DEPENDS:=python/host
HOST_BUILD_DEPENDS:=python/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/pytz
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
  TITLE:=World timezone definitions, modern and historical
  URL:=https://sourceforge.net/projects/pytz/
  DEPENDS:=+python
endef

define Package/pytz/description
  World timezone definitions, modern and historical
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Host/Compile
	$(call Build/Compile/HostPyMod,,install --prefix="" --root="$(STAGING_DIR_HOSTPKG)")
endef

Host/Install:=

define Package/pytz/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,pytz))
