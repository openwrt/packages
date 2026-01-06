#
# Copyright (C) 2022 Nita Vesa (werecatf@outlook.com)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gensio
PKG_VERSION:=2.8.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/ser2net
PKG_HASH:=28807dce0373f04271d44e1cdd38aa9486f3dd3060867b9acd370ece10404f62

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Nita Vesa <werecatf@outlook.com>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PYTHON3_PKG_BUILD:=0

PKG_CONFIG_DEPENDS:= \
	CONFIG_GENSIO_SSL \
	CONFIG_GENSIO_WRAP \
	CONFIG_GENSIO_SCTP \
	CONFIG_GENSIO_PTHREADS \
	CONFIG_GENSIO_AVAHI \
	CONFIG_GENSIO_GLIB \
	CONFIG_GENSIO_TCL \
	CONFIG_GENSIO_SSHD

PKG_BUILD_DEPENDS:=PACKAGE_python3-gensio:swig/host

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

CONFIGURE_ARGS += \
	--$(if $(CONFIG_GENSIO_AVAHI),with,without)-avahi \
	--$(if $(CONFIG_GENSIO_SSL),with,without)-openssl \
	--$(if $(CONFIG_GENSIO_SCTP),with,without)-sctp \
	--$(if $(CONFIG_GENSIO_WRAP),with,without)-tcp-wrappers \
	--$(if $(CONFIG_GENSIO_PTHREADS),with,without)-pthreads \
	--$(if $(CONFIG_GENSIO_GLIB),with,without)-glib \
	--$(if $(CONFIG_GENSIO_TCL),with,without)-tcl \
	--without-afskmdm \
	--without-alsa \
	--without-ax25 \
	--without-cm108gpio \
	--without-dnssd \
	--without-go \
	--without-ipmisol \
	--without-kiss \
	--without-openipmi \
	--without-portaudio \
	--without-sound \
	--without-udev \
	--with-cplusplus \
	--with-flock-locking \
	--with-uucp-locking \
	--disable-doc

CONFIGURE_VARS += \
	ac_cv_lib_avahi_client_avahi_client_new=$(if $(CONFIG_GENSIO_AVAHI),yes,no) \
	ac_cv_lib_pam_pam_start=$(if $(CONFIG_GENSIO_SSHD),yes,no)

ifneq ($(CONFIG_PACKAGE_python3-gensio),)
CONFIGURE_ARGS += \
	--with-swig \
	--with-python \
	--with-pythoninstall=$(PYTHON3_PKG_DIR)

CONFIGURE_VARS += \
	PYTHON_LIBS="$(shell $(STAGING_DIR)/host/bin/$(PYTHON3)-config --ldflags) -l${PYTHON3}" \
	PYTHON_CPPFLAGS="$(shell $(STAGING_DIR)/host/bin/$(PYTHON3)-config --includes)" \
	PYTHON="$(STAGING_DIR_HOSTPKG)/bin/$(PYTHON3)"

MAKE_VARS += \
	PYTHON_LIBS="$(shell $(STAGING_DIR)/host/bin/$(PYTHON3)-config --ldflags) -l${PYTHON3}"
else
CONFIGURE_ARGS += \
	--without-python \
	--without-swig
endif

define Package/gensio/Default
  TITLE:=Abstract stream I/O
  URL:=https://github.com/cminyard/gensio
endef

define Package/gensio/Default/description
 This project (pronounced gen'-see-oh) is used to abstract stream I/O
 like serial port, TCP, telnet, UDP, SSL, IPMI SOL etc and offers a
 framework for giving a consistent view of various stream (and packet)
 I/O types. You create a gensio object (or a gensio), and you can use
 that gensio without having to know too much about what is going on
 underneath. You can stack gensio on top of another one to add protocol
 functionality. For instance, you can create a TCP gensio, stack SSL on
 top of that, and stack Telnet on top of that. It supports a number of
 network I/O and serial ports.  Gensio can be used for sending and
 receiving ports, and it also supports establishing encrypted and
 authenticated connections.
endef

define Package/libgensio
$(call Package/gensio/Default)
  TITLE+= (runtime files)
  SECTION:=libs
  CATEGORY:=Libraries
  ABI_VERSION:=0
  MENU:=1
  DEPENDS:=+GENSIO_SSL:libopenssl +GENSIO_WRAP:libwrap +(IPV6&&GENSIO_SCTP):libsctp +GENSIO_PTHREADS:libpthread +GENSIO_AVAHI:libavahi-client +GENSIO_TCL:tcl +GENSIO_GLIB:glib2 +GENSIO_SSHD:libpam
endef

define Package/libgensio/description
$(call Package/gensio/Default/description)
 .
 This package contains the runtime libraries.
endef

define Package/libgensio/config
	source "$(SOURCE)/Config.in"
endef

define Package/gensio-bin
$(call Package/gensio/Default)
  TITLE+= (command-line tools)
  SECTION:=net
  CATEGORY:=Network
  MENU:=1
  DEPENDS:=+libgensio
endef

define Package/gensio-bin/description
$(call Package/gensio/Default/description)
 .
 This package contains the command-line tools.
endef

define Package/gensio-bin/config
	source "$(SOURCE)/Config-bin.in"
endef

define Package/python3-gensio
$(call Package/gensio/Default)
  TITLE+= (Python bindings)
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  DEPENDS:=+PACKAGE_python3-gensio:python3-light +libgensiocpp
endef

define Package/python3-gensio/description
$(call Package/gensio/Default/description)
 .
 This package contains the Python3-bindings for libgensio.
endef

define Package/libgensiocpp
$(call Package/gensio/Default)
  TITLE+= (C++ - bindings)
  SECTION:=libs
  CATEGORY:=Libraries
  ABI_VERSION:=0
  DEPENDS:=+libgensio +PACKAGE_libgensiocpp:libstdcpp
endef

define Package/libgensiocpp/description
$(call Package/gensio/Default/description)
 .
 This package contains the C++ runtime files.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/gensio/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/gensio/* $(1)/usr/include/gensio/
	$(INSTALL_DIR) $(1)/usr/lib/gensio
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.{so*,a,la} $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/gensio/* $(1)/usr/lib/gensio/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig/
ifneq ($(CONFIG_PACKAGE_python3-gensio),)
	$(INSTALL_DIR) $(1)/$(PYTHON3_PKG_DIR)
	$(CP) $(PKG_INSTALL_DIR)/$(PYTHON3_PKG_DIR)/*.{so*,a,la} $(1)/$(PYTHON3_PKG_DIR)
	$(CP) $(PKG_INSTALL_DIR)/$(PYTHON3_PKG_DIR)/*.py* $(1)/$(PYTHON3_PKG_DIR)
endif
endef

define Package/libgensio/install
	$(INSTALL_DIR) $(1)/usr/lib/gensio
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgensio.so.* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgensioosh.so.* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgensiomdns.so.* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/gensio/* $(1)/usr/lib/gensio/
ifeq ($(CONFIG_GENSIO_GLIB),y)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgensioglib.so.* $(1)/usr/lib/
endif
endef

define Package/gensio-bin/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
ifeq ($(CONFIG_GENSIO_SSHD),y)
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/* $(1)/usr/sbin/
endif
endef

define Package/python3-gensio/install
	$(INSTALL_DIR) $(1)/$(PYTHON3_PKG_DIR)
	$(CP) $(PKG_INSTALL_DIR)/$(PYTHON3_PKG_DIR)/*.so* $(1)/$(PYTHON3_PKG_DIR)
	$(CP) $(PKG_INSTALL_DIR)/$(PYTHON3_PKG_DIR)/*.py* $(1)/$(PYTHON3_PKG_DIR)

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgensio_python_swig.so.* $(1)/usr/lib/
endef

define Package/libgensiocpp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgensio*cpp.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libgensio))
$(eval $(call BuildPackage,gensio-bin))
$(eval $(call BuildPackage,python3-gensio))
$(eval $(call BuildPackage,libgensiocpp))
