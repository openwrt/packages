#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=micropython
PKG_VERSION:=1.18
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/micropython/micropython/releases/download/v$(PKG_VERSION)
PKG_HASH:=96fc71b42ed331c64e1adc5a830ec4f29f2975c23e8751109c03f32b80fa3eb4

PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/micropython/default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=MicroPython
  URL:=https://micropython.org
  DEPENDS:=+libffi
  PROVIDES:=micropython
endef

define Package/micropython-mbedtls
$(call Package/micropython/default)
  TITLE+= (mbedtls)
  DEPENDS+= +libmbedtls
  VARIANT:=mbedtls
  DEFAULT_VARIANT:=1
endef

define Package/micropython-nossl
$(call Package/micropython/default)
  TITLE+= (nossl)
  VARIANT:=nossl
endef

define Package/micropython/default/description
  MicroPython is a lean and efficient implementation of the Python 3
  programming language that includes a small subset of the Python
  standard library and is optimised to run on microcontrollers and in
  constrained environments.
endef

define Package/micropython-mbedtls/description
$(call Package/micropython/default/description)

  This version uses the Mbed TLS library.
endef

define Package/micropython-nossl/description
$(call Package/micropython/default/description)

  This version is built without TLS and upip.
endef

MAKE_FLAGS += BUILD_VERBOSE=1

ifneq ($(CONFIG_DEBUG),)
  MAKE_FLAGS += DEBUG=1
endif

ifeq ($(BUILD_VARIANT),mbedtls)
  MAKE_FLAGS += MICROPY_SSL_AXTLS=0 MICROPY_SSL_MBEDTLS=1
endif

ifeq ($(BUILD_VARIANT),nossl)
  MAKE_FLAGS += MICROPY_PY_USSL=0 FROZEN_MANIFEST=
endif

MAKE_PATH = ports/unix

define Build/Compile
	+$(HOST_MAKE_VARS) \
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/mpy-cross \
		$(HOST_MAKE_FLAGS) BUILD_VERBOSE=1
	$(call Build/Compile/Default)
endef

define Package/micropython/default/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ports/unix/micropython $(1)/usr/bin/
endef

Package/micropython-mbedtls/install = $(Package/micropython/default/install)
Package/micropython-nossl/install = $(Package/micropython/default/install)

$(eval $(call BuildPackage,micropython-mbedtls))
$(eval $(call BuildPackage,micropython-nossl))
