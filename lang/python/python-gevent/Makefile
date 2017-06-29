#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gevent
PKG_VERSION:=1.2.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/1b/92/b111f76e54d2be11375b47b213b56687214f258fd9dae703546d30b837be/
PKG_MD5SUM:=7f0baf355384fe5ff2ecf66853422554

PKG_BUILD_DEPENDS:=python python-setuptools cython
PKG_USE_MIPS16:=0
PKG_MAINTAINER:=V.E.O <VEO at live.com>

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-gevent
	SECTION:=lang
	CATEGORY:=Languages
	SUBMENU:=Python
	MAINTAINER:=V.E.O <veo at live.com>
	TITLE:=Coroutine-based concurrency library for Python
	URL:=http://www.gevent.org/
	DEPENDS:=+python-light +python-greenlet
endef

define Package/python-gevent/description
gevent is a coroutine-based Python networking library.
endef

define Build/Prepare
$(call Build/Prepare/Default)
	rm -f $(PKG_BUILD_DIR)/src/gevent/{_socket,_ssl}3.py
endef

define Build/Compile
	(cd $(PKG_BUILD_DIR)/libev; \
		$(TARGET_CONFIGURE_OPTS) \
                CFLAGS="$(TARGET_CFLAGS)" \
                CPPFLAGS="-I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/include" \
                LDFLAGS="-L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib" \
		$(PKG_BUILD_DIR)/libev/configure \
			--target=$(GNU_TARGET_NAME) \
                        --host=$(GNU_TARGET_NAME) \
                        --build=$(GNU_HOST_NAME) \
                        --prefix=/usr \
	);
	$(call Build/Compile/PyMod,., \
		install --prefix="/usr" --root="$(PKG_INSTALL_DIR)", \
		CYTHON="$(STAGING_DIR_HOST)/usr/bin/cython" \
	)
endef

$(eval $(call BuildPackage,python-gevent))
