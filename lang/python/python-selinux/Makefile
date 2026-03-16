#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-selinux
PKG_VERSION:=3.9
PKG_RELEASE:=1

SRC_NAME:=libselinux
PKG_SOURCE:=$(SRC_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/SELinuxProject/selinux/releases/download/$(PKG_VERSION)
PKG_HASH:=e7ee2c01dba64a0c35c9d7c9c0e06209d8186b325b0638a0d83f915cc3c101e8
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(SRC_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Thomas Petazzoni <thomas.petazzoni@bootlin.com>
PKG_LICENSE:=libselinux-1.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:selinuxproject:libselinux

PKG_BUILD_DEPENDS:= \
	swig/host \
	python-setuptools/host
PKG_BUILD_PARALLEL:=1
PYTHON3_PKG_BUILD:=0

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-selinux
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=SELinux runtime library bindings
  DEPENDS:=+python3-light +libselinux
  URL:=http://selinuxproject.org/page/Main_Page
endef

define Package/python3-selinux/description
	libselinux is the runtime SELinux library that provides
	interfaces (e.g. library functions for the SELinux kernel
	APIs like getcon(), other support functions like
	getseuserbyname()) to SELinux-aware applications. libselinux
	may use the shared libsepol to manipulate the binary policy
	if necessary (e.g. to downgrade the policy format to an
	older version supported by the kernel) when loading policy.

	This package provides the Python bindings for libselinux.
endef

MAKE_VARS += \
	$(PYTHON3_VARS) \
	$(HOST_PYTHON3_PIP_VARS) \
	PYTHON_SETUP_ARGS=--no-compile

MAKE_FLAGS += \
	SHLIBDIR=/usr/lib

ifneq ($(CONFIG_USE_MUSL),)
  MAKE_FLAGS += FTS_LDLIBS=-lfts
  TARGET_CFLAGS += -D_LARGEFILE64_SOURCE
endif

define Build/Compile
	$(call Build/Compile/Default,pywrap)
endef

define Build/Install
	$(call Build/Install/Default,install-pywrap)
endef

$(eval $(call Py3Package,python3-selinux))
$(eval $(call BuildPackage,python3-selinux))
$(eval $(call BuildPackage,python3-selinux-src))
