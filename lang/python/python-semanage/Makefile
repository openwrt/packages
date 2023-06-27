#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-semanage
PKG_VERSION:=3.5
PKG_RELEASE:=1

SRC_NAME:=libsemanage
PKG_SOURCE:=$(SRC_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/SELinuxProject/selinux/releases/download/$(PKG_VERSION)
PKG_HASH:=f53534e50247538280ed0d76c6ce81d8fb3939bd64cadb89da10dba42e40dd9c
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(SRC_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Thomas Petazzoni <thomas.petazzoni@bootlin.com>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:selinuxproject:libsemanage

PKG_BUILD_DEPENDS:=swig/host
PKG_BUILD_PARALLEL:=1
PYTHON3_PKG_BUILD:=0

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-semanage
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=SELinux policy management library bindings
  DEPENDS:=+python3-light +libsemanage
  URL:=http://selinuxproject.org/page/Main_Page
endef

define Package/python3-semanage/description
	libsemanage is the policy management library. It uses
	libsepol for binary policy manipulation and libselinux for
	interacting with the SELinux system. It also exec's helper
	programs for loading policy and for checking whether the
	file_contexts configuration is valid (load_policy and
	setfiles from policycoreutils) presently, although this may
	change at least for the bootstrapping case (for rpm).

	This package provides the Python bindings for libsemanage.
endef

MAKE_VARS += \
	$(PYTHON3_VARS)

define Build/Compile
	$(call Build/Compile/Default,pywrap)
endef

define Build/Install
	$(call Build/Install/Default,install-pywrap)
endef

$(eval $(call Py3Package,python3-semanage))
$(eval $(call BuildPackage,python3-semanage))
$(eval $(call BuildPackage,python3-semanage-src))
