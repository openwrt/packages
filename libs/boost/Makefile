#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

# 
# Original Boost 1.51 Makefile by Mirko Vogt <mirko@openwrt.org>
# Dude, this "boost" is really one of the most crude stuff I ported yet.
#


include $(TOPDIR)/rules.mk

PKG_NAME:=boost
PKG_VERSION:=1_57_0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/boost
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_$(PKG_VERSION)
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/$(PKG_NAME)_$(PKG_VERSION)
PKG_MD5SUM:=25f9a8ac28beeb5ab84aa98510305299
PKG_LICENSE:=Boost Software License <http://www.boost.org/users/license.html>
PKG_MAINTAINER:=Carlos M. Ferreira <carlosmf.pt@gmail.com> (Modified from Mirko Vogt <mirko@openwrt.org> Boost 1.51 Original Makefile and patches)


PKG_BUILD_DEPENDS:=boost/host
PKG_BUILD_PARALLEL:=0
PKG_USE_MIPS16:=0

PKG_CONFIG_DEPENDS := \
	CONFIG_PACKAGE_boost-date_time \
	CONFIG_PACKAGE_boost-filesystem \
	CONFIG_PACKAGE_boost-graph \
	CONFIG_PACKAGE_boost-iostreams \
	CONFIG_PACKAGE_boost-math \
	CONFIG_PACKAGE_boost-program_options \
	CONFIG_PACKAGE_boost-python \
	CONFIG_PACKAGE_boost-regex \
	CONFIG_PACKAGE_boost-serialization \
	CONFIG_PACKAGE_boost-signals \
	CONFIG_PACKAGE_boost-system \
	CONFIG_PACKAGE_boost-test \
	CONFIG_PACKAGE_boost-thread \
	CONFIG_PACKAGE_boost-wave \
        CONFIG_PACKAGE_boost-atomic \


include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/boost/Default
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Boost C++ source libraries
  URL:=http://www.boost.org
  DEPENDS:=+libstdcpp +libpthread +librt
endef

define Package/boost/Default/description
  Boost provides free peer-reviewed portable C++ source libraries
endef

define Package/boost-atomic
  $(call Package/boost/Default)
  TITLE+= (atomic)
  DEPENDS+= +boost-system
endef

define Package/boost-chrono
  $(call Package/boost/Default)
  TITLE+= (chrono)
  DEPENDS+= +boost-system
endef

define Package/boost-date_time
  $(call Package/boost/Default)
  TITLE+= (date_time)
endef

define Package/boost-exception
  $(call Package/boost/Default)
  TITLE+= (exception)
endef

define Package/boost-filesystem
  $(call Package/boost/Default)
  TITLE+= (filesystem)
  DEPENDS+= +boost-system
endef

define Package/boost-graph
  $(call Package/boost/Default)
  TITLE+= (graph)
  DEPENDS+= +boost-regex
endef

define Package/boost-graph_parallel
  $(call Package/boost/Default)
  TITLE+= (graph_parallel)
endef

define Package/boost-iostreams
  $(call Package/boost/Default)
  TITLE+= (iostreams)
  DEPENDS+= +zlib
endef

define Package/boost-locale
  $(call Package/boost/Default)
  TITLE+= (locale)
endef

define Package/boost-math
  $(call Package/boost/Default)
  TITLE+= (math)
endef

define Package/boost-mpi
  $(call Package/boost/Default)
  TITLE+= (mpi)
endef

define Package/boost-program_options
  $(call Package/boost/Default)
  TITLE+= (program_options)
endef

define Package/boost-python
  $(call Package/boost/Default)
  TITLE+= (python)
  DEPENDS+= +PACKAGE_boost-python:python
endef

define Package/boost-random
  $(call Package/boost/Default)
  TITLE+= (random)
  DEPENDS+= +boost-system
endef

define Package/boost-regex
  $(call Package/boost/Default)
  TITLE+= (regex)
endef

define Package/boost-serialization
  $(call Package/boost/Default)
  TITLE+= (serialization)
endef

define Package/boost-signals
  $(call Package/boost/Default)
  TITLE+= (signals)
endef

define Package/boost-system
  $(call Package/boost/Default)
  TITLE+= (system)
endef

define Package/boost-test
  $(call Package/boost/Default)
  TITLE+= (test)
endef

define Package/boost-thread
  $(call Package/boost/Default)
  TITLE+= (thread)
  DEPENDS+= +boost-system +boost-chrono +boost-atomic
endef

define Package/boost-timer
  $(call Package/boost/Default)
  TITLE+= (timer)
  DEPENDS+= boost-chrono
endef

define Package/boost-wave
  $(call Package/boost/Default)
  TITLE+= (wave)
  DEPENDS+= +boost-date_time +boost-thread +boost-filesystem
endef

define Package/boost
  $(call Package/boost/Default)
  TITLE+= (header-only)
  BUILDONLY:=1
endef

define Build/Configure
endef

define Host/Compile
	# bjam does not provide a configure-script nor a Makefile
	( cd $(HOST_BUILD_DIR)/tools/build/src/engine ; ./build.sh gcc )
endef

CONFIGURE_PREFIX:=$(PKG_INSTALL_DIR)
TARGET_LDFLAGS += -pthread -lrt

define Build/Compile
	( cd $(PKG_BUILD_DIR) ; \
		echo "using gcc : $(ARCH) : $(GNU_TARGET_NAME)-gcc : <compileflags>\"$(TARGET_CFLAGS)\" <cxxflags>\"$(TARGET_CXXFLAGS)\" <linkflags>\"$(TARGET_LDFLAGS)\" ;" > tools/build/src/user-config.jam ; \
		$(if $(CONFIG_PACKAGE_boost-python), \
			echo "using python : : $(STAGING_DIR_ROOT)/usr/bin/python :	$(STAGING_DIR)/usr/include/python2.7/ ;" >> \
				tools/build/src/user-config.jam; \
		) \
		bjam \
			'-sBUILD=release <optimization>space <inlining>on <debug-symbols>off' \
			--toolset=gcc-$(ARCH) --build-type=minimal --layout=system \
			--disable-long-double \
			$(CONFIGURE_ARGS) \
			$(if $(CONFIG_PACKAGE_boost-atomic),,--without-atomic) \
			$(if $(CONFIG_PACKAGE_boost-chrono),,--without-chrono) \
			$(if $(CONFIG_PACKAGE_boost-date_time),,--without-date_time) \
			$(if $(CONFIG_PACKAGE_boost-exception),,--without-exception) \
			$(if $(CONFIG_PACKAGE_boost-filesystem),,--without-filesystem) \
			$(if $(CONFIG_PACKAGE_boost-graph),,--without-graph) \
			$(if $(CONFIG_PACKAGE_boost-graph_parallel),,--without-graph_parallel) \
			$(if $(CONFIG_PACKAGE_boost-iostreams),,--without-iostreams) \
			$(if $(CONFIG_PACKAGE_boost-locale),,--without-locale) \
			$(if $(CONFIG_PACKAGE_boost-math),,--without-math) \
			$(if $(CONFIG_PACKAGE_boost-mpi),,--without-mpi) \
			$(if $(CONFIG_PACKAGE_boost-program_options),,--without-program_options) \
			$(if $(CONFIG_PACKAGE_boost-python),,--without-python) \
			$(if $(CONFIG_PACKAGE_boost-random),,--without-random) \
			$(if $(CONFIG_PACKAGE_boost-regex),,--without-regex) \
			$(if $(CONFIG_PACKAGE_boost-serialization),,--without-serialization) \
			$(if $(CONFIG_PACKAGE_boost-signals),,--without-signals) \
			$(if $(CONFIG_PACKAGE_boost-system),,--without-system) \
			$(if $(CONFIG_PACKAGE_boost-test),,--without-test) \
			$(if $(CONFIG_PACKAGE_boost-thread),,--without-thread) \
			$(if $(CONFIG_PACKAGE_boost-timer),,--without-timer) \
			$(if $(CONFIG_PACKAGE_boost-wave),,--without-wave) \
			\
			$(if $(CONFIG_PACKAGE_boost-iostreams),-sNO_BZIP2=1 -sZLIB_INCLUDE=$(STAGING_DIR)/usr/include \
				-sZLIB_LIBPATH=$(STAGING_DIR)/usr/lib) \
			install \
	)
endef

define Build/InstallDev
	$(INSTALL_DIR) \
		$(1)/usr/include/boost/

	$(CP) \
		$(PKG_INSTALL_DIR)/include/boost/* \
		$(1)/usr/include/boost/ \
		# copies _all_ header files - independent of <--with-library>-argument above

	if [ -d $(PKG_INSTALL_DIR)/lib ]; then \
		$(INSTALL_DIR) \
			$(1)/usr/lib; \
		$(CP) \
			$(PKG_INSTALL_DIR)/lib/*.a \
			$(1)/usr/lib/; \
		$(CP) \
			$(PKG_INSTALL_DIR)/lib/*.so* \
			$(1)/usr/lib/; \
	fi
endef

define Host/Install
	$(INSTALL_DIR) \
		$(STAGING_DIR_HOST)/bin

	$(CP) \
		$(HOST_BUILD_DIR)/tools/build/src/engine/bin.*/bjam \
		$(STAGING_DIR_HOST)/bin/
endef

define Package/boost/Default/install
	$(INSTALL_DIR) \
		$(1)/usr/lib

	$(CP) \
		$(PKG_INSTALL_DIR)/lib/libboost_$(2)*.so* \
		$(1)/usr/lib/
endef

define Package/boost-atomic/install
  $(call Package/boost/Default/install,$(1),atomic)
endef

define Package/boost-chrono/install
  $(call Package/boost/Default/install,$(1),chrono)
endef

define Package/boost-date_time/install
  $(call Package/boost/Default/install,$(1),date_time)
endef

define Package/boost-exception/install
  $(call Package/boost/Default/install,$(1),exception)
endef

define Package/boost-filesystem/install
  $(call Package/boost/Default/install,$(1),filesystem)
endef

define Package/boost-graph/install
  $(call Package/boost/Default/install,$(1),graph)
endef

define Package/boost-graph_parallel/install
  $(call Package/boost/Default/install,$(1),graph_parallel)
endef

define Package/boost-iostreams/install
  $(call Package/boost/Default/install,$(1),iostreams)
endef

define Package/boost-math/install
  $(call Package/boost/Default/install,$(1),math)
endef

define Package/boost-mpi/install
  $(call Package/boost/Default/install,$(1),mpi)
endef

define Package/boost-program_options/install
  $(call Package/boost/Default/install,$(1),program_options)
endef

define Package/boost-python/install
  $(call Package/boost/Default/install,$(1),python)
endef

define Package/boost-random/install
  $(call Package/boost/Default/install,$(1),random)
endef

define Package/boost-regex/install
  $(call Package/boost/Default/install,$(1),regex)
endef

define Package/boost-serialization/install
  $(call Package/boost/Default/install,$(1),serialization)
endef

define Package/boost-signals/install
  $(call Package/boost/Default/install,$(1),signals)
endef

define Package/boost-system/install
  $(call Package/boost/Default/install,$(1),system)
endef

define Package/boost-test/install
	$(INSTALL_DIR) \
		$(1)/usr/lib

	$(CP) \
		$(PKG_INSTALL_DIR)/lib/libboost_unit_test_framework*.so* \
		$(1)/usr/lib/

	$(CP) \
		$(PKG_INSTALL_DIR)/lib/libboost_prg_exec_monitor*.so* \
		$(1)/usr/lib/
endef

define Package/boost-thread/install
  $(call Package/boost/Default/install,$(1),thread)
endef

define Package/boost-timer/install
  $(call Package/boost/Default/install,$(1),timer)
endef

define Package/boost-wave/install
  $(call Package/boost/Default/install,$(1),wave)
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,boost))
$(eval $(call BuildPackage,boost-atomic))
$(eval $(call BuildPackage,boost-chrono))
$(eval $(call BuildPackage,boost-date_time))
#$(eval $(call BuildPackage,boost-exception))
$(eval $(call BuildPackage,boost-filesystem))
$(eval $(call BuildPackage,boost-graph))
#$(eval $(call BuildPackage,boost-graph_parallel))
$(eval $(call BuildPackage,boost-iostreams))
$(eval $(call BuildPackage,boost-locale))
$(eval $(call BuildPackage,boost-math))
#$(eval $(call BuildPackage,boost-mpi))
$(eval $(call BuildPackage,boost-program_options))
$(eval $(call BuildPackage,boost-random))
$(eval $(call BuildPackage,boost-python))
$(eval $(call BuildPackage,boost-regex))
$(eval $(call BuildPackage,boost-serialization))
$(eval $(call BuildPackage,boost-signals))
$(eval $(call BuildPackage,boost-system))
$(eval $(call BuildPackage,boost-test))
$(eval $(call BuildPackage,boost-thread))
$(eval $(call BuildPackage,boost-timer))
$(eval $(call BuildPackage,boost-wave))
