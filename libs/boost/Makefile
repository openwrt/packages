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
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/target.mk 

PKG_NAME:=boost
PKG_VERSION:=1_58_0
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/boost
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_$(PKG_VERSION)
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/$(PKG_NAME)_$(PKG_VERSION)
PKG_MD5SUM:=5a5d5614d9a07672e1ab2a250b5defc5
PKG_LICENSE:=Boost Software License <http://www.boost.org/users/license.html>
PKG_MAINTAINER:=Carlos M. Ferreira <carlosmf.pt@gmail.com>

PKG_BUILD_DEPENDS += boost/host 
PKG_BUILD_PARALLEL:=0
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk


define Package/boost/Default
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Boost C++ source library
  URL:=http://www.boost.org
  DEPENDS:=+libstdcpp +libpthread +librt
endef

define Package/boost/description/Default
  Boost provides free peer-reviewed portable C++ source libraries
endef

BOOST_LIBS =

define Package/boost-libs
$(call Package/boost/Default)
  TITLE+= (all libs)
  DEPENDS+= $(BOOST_DEPENDS)
  HIDDEN:=1
endef

define Package/boost-libs/description
$(call Package/boost/description/Default)
 .
 This meta package contains only dependencies to the other libraries from
 the boost libraries collection.
endef

# Create a meta-package of dependent libraries (for ALL)
define Package/boost-libs/install
  true
endef

define Package/boost
  $(call Package/boost/Default)
  TITLE+= packages
  DEPENDS:=+ALL:boost-libs +ALL:boost-test
endef

define Package/boost/config
    menu "Select Boost libraries"
      depends on PACKAGE_boost

    config boost-libs-all
      bool "Include all Boost libraries"
      select PACKAGE_boost-libs

   config boost-test-pkg
     bool "Boost test package"
     select PACKAGE_boost-test

    comment "Libraries"

    $(foreach lib,$(BOOST_LIBS), \
        config PACKAGE_boost-$(lib)
           prompt "Boost $(lib) library"

   )

  endmenu

endef

PKG_CONFIG_DEPENDS:= CONFIG_PACKAGE_boost-test

define Package/boost-test
  $(call Package/boost/Default)
  TITLE+= (test)
  HIDDEN:=1
endef

define Build/Configure
endef

# 1: short name
# 2: dependencies on other boost libraries (short name)
# 3: dependencies on other packages
define DefineBoostLibrary

  BOOST_DEPENDS+= +boost-$(1) 
  BOOST_LIBS+= $(1)

  PKG_CONFIG_DEPENDS+= CONFIG_PACKAGE_boost-$(1)

  define Package/boost-$(1)
    $(call Package/boost/Default)
    TITLE+= ($(1))
    DEPENDS+= $$(foreach lib,$(2),+boost-$$(lib)) $(3)
    HIDDEN:=1
  endef

  define Package/boost-$(1)/description
   $(call Package/boost/description/Default)
   .
   This package contains the Boost $(1) library.
  endef
endef

$(eval $(call DefineBoostLibrary,atomic,system,))
$(eval $(call DefineBoostLibrary,chrono,system,))
$(eval $(call DefineBoostLibrary,container,,))
$(eval $(call DefineBoostLibrary,context,chrono system thread,))
$(eval $(call DefineBoostLibrary,coroutine,system chrono context thread,))
$(eval $(call DefineBoostLibrary,date_time,,))
#$(eval $(call DefineBoostLibrary,exception,,))
$(eval $(call DefineBoostLibrary,filesystem,system,))
$(eval $(call DefineBoostLibrary,graph,regex,))
#$(eval $(call DefineBoostLibrary,graph_parallel,,))
$(eval $(call DefineBoostLibrary,iostreams,,+zlib))
$(eval $(call DefineBoostLibrary,locale,system,$(ICONV_DEPENDS)))
$(eval $(call DefineBoostLibrary,log,system chrono date_time thread filesystem regex,))
$(eval $(call DefineBoostLibrary,math,,))
#$(eval $(call DefineBoostLibrary,mpi,,))
$(eval $(call DefineBoostLibrary,program_options,,))
$(eval $(call DefineBoostLibrary,random,system,))

# We need a beter way to provide this package, information regarding the Python packages
#  such as Python version and directories locations. 
# Python 2.7 version is for now hard-coded. Python 3 is (until this date) broken in the trunk tree.
$(eval $(call DefineBoostLibrary,python,,+PACKAGE_boost-python:python))
$(eval $(call DefineBoostLibrary,regex,,))
$(eval $(call DefineBoostLibrary,serialization,,))
$(eval $(call DefineBoostLibrary,signals,,))
$(eval $(call DefineBoostLibrary,system,,))
$(eval $(call DefineBoostLibrary,thread,system chrono atomic,))
$(eval $(call DefineBoostLibrary,timer,chrono))
$(eval $(call DefineBoostLibrary,wave,date_time thread filesystem,))

define Host/Compile
	# bjam does not provide a configure-script nor a Makefile
	( cd $(HOST_BUILD_DIR)/tools/build/src/engine ; ./build.sh gcc )
endef

CONFIGURE_PREFIX:=$(PKG_INSTALL_DIR)
TARGET_LDFLAGS += -pthread -lrt


ifneq ($(findstring mips,$(ARCH)),)
    BOOST_ABI = o32
    ifneq ($(findstring 64,$(ARCH)),)
        BOOST_ABI = o64
    endif
else ifneq ($(findstring arm,$(ARCH)),)
    BOOST_ABI = aapcs
else ifeq ($(ARCH),aarch64)
    BOOST_ABI = aapcs
else
    BOOST_ABI = sysv
endif


define Build/Compile
	$(info Selected Boost API $(BOOST_ABI) for architecture $(ARCH) and cpu $(CPU_TYPE) $(CPU_SUBTYPE))
	( cd $(PKG_BUILD_DIR) ; \
		echo "using gcc : $(ARCH) : $(GNU_TARGET_NAME)-gcc : <compileflags>\"$(TARGET_CFLAGS)\" <cxxflags>\"$(TARGET_CXXFLAGS)\" <linkflags>\"$(TARGET_LDFLAGS)\" ;" > tools/build/src/user-config.jam ; \
		$(if $(CONFIG_PACKAGE_boost-python), \
			echo "using python : : $(STAGING_DIR_ROOT)/usr/bin/python :	$(STAGING_DIR)/usr/include/python2.7/ ;" >> \
				tools/build/src/user-config.jam; \
		) \
		bjam \
			'-sBUILD=release <optimization>space <inlining>on <debug-symbols>off' \
			--toolset=gcc-$(ARCH) --build-type=minimal --layout=system abi=$(BOOST_ABI) \
			--disable-long-double \
			$(CONFIGURE_ARGS) \
			--without-mpi \
			$(if $(CONFIG_PACKAGE_boost-test),,--without-test) \
			$(foreach lib,$(BOOST_LIBS), \
				$(if $(CONFIG_PACKAGE_boost-$(lib)),,--without-$(lib)) \
			) \
			$(if $(CONFIG_PACKAGE_boost-locale),boost.locale.iconv=on -sICONV_PATH=$(ICONV_PREFIX) boost.locale.posix=$(if $(USE_UCLIBC),on,off), \
				boost.locale.iconv=off) \
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

define BuildBoostLibrary
  define Package/boost-$(1)/install
	$(call Package/boost/Default/install,$$(1),$(1))
  endef

  $$(eval $$(call BuildPackage,boost-$(1)))
endef

$(eval $(call HostBuild))

$(foreach lib,$(BOOST_LIBS),$(eval $(call BuildBoostLibrary,$(lib))))
$(eval $(call BuildPackage,boost-test))

$(eval $(call BuildPackage,boost-libs))
$(eval $(call BuildPackage,boost))
