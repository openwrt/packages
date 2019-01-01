# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python3-lxc
PKG_VERSION:=2.1.1
PKG_RELEASE:=1

PKG_LICENSE:=LGPL-2.1+ BSD-2-Clause GPL-2.0
PKG_MAINTAINER:=Daniel Dickinson <cshored@thecshore.com>

PKG_SOURCE:=lxc-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://linuxcontainers.org/downloads/lxc/
PKG_HASH:=68663a67450a8d6734e137eac54cc7077209fb15c456eec401a2c26e6386eff6
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_FIXUP:=autoreconf
PKG_AUTOMAKE_DIRS:=src src/python-lxc

PKG_BUILD_DEPENDS:=lxc

PYTHON3_PKG_OLD:=0

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python3-lxc
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=LXC Python3 bindings
  DEPENDS:=@LXC_PYTHON +python3-light +liblxc
  URL:=http://lxc.sourceforge.net/
  VARIANT:=python3
endef

define Package/python3-lxc/description
 LXC is the userspace control package for Linux Containers, a lightweight
 virtual system mechanism sometimes described as "chroot on steroids".
 .
 This package contains the Python 3.7 bindings.
endef

CONFIGURE_ARGS += \
	--disable-api-docs \
	--disable-apparmor \
	--disable-bash \
	--disable-doc \
	--disable-examples \
	--disable-gnutls \
	--disable-selinux \
	--disable-cgmanager \
	--disable-examples \
	--enable-lua=yes \
	--with-lua-pc="$(STAGING_DIR)/usr/lib/pkgconfig/lua.pc"

ifeq ($(CONFIG_LXC_SECCOMP),y)
CONFIGURE_ARGS+=\
	--enable-seccomp
else
CONFIGURE_ARGS+=\
	--disable-seccomp
endif

CONFIGURE_ARGS+=\
	--enable-python=yes

PYTHON3_PKG_build_ext_SUBDIR:=src/python-lxc
PYTHON3_PKG_install_SUBDIR:=src/python-lxc
PYTHON3_PKG_build_ext_ARGS:=build_ext --no-pkg-config

$(eval $(call Py3Package,python3-lxc))

define Package/python3-lxc-src
$(call Package/python3-lxc)
  DEPENDS:=@LXC_PYTHON
  TITLE+= (sources)
endef

$(eval $(call BuildPackage,python3-lxc))
$(eval $(call BuildPackage,python3-lxc-src))
