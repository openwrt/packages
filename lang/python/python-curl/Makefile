#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pycurl
PKG_VERSION:=7.43.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Waldemar Konik <informatyk74@interia.pl>
PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILE=COPYING-LGPL

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://dl.bintray.com/pycurl/pycurl/
PKG_HASH:=aa975c19b79b6aa6c0518c0cc2ae33528900478f0b500531dbcdbf05beec584c

PKG_BUILD_DEPENDS:=python libcurl

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-curl
  CATEGORY:=Languages
  SECTION:=lang
  SUBMENU:=Python
  TITLE:=Python module interface to the cURL library
  URL:=http://pycurl.io/
  DEPENDS:=+python +libcurl
endef

define Package/python-curl/description
Python module interface to the cURL library.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/python-curl/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
		$(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
		$(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,python-curl))
