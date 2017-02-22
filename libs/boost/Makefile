#
# Copyright (C) 2015-2017 OpenWrt.org
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
PKG_VERSION:=1.63.0
PKG_SOURCE_VERSION:=1_63_0
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)_$(PKG_SOURCE_VERSION).tar.bz2
PKG_SOURCE_URL:=https://sourceforge.net/projects/boost/files/boost/$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_$(PKG_SOURCE_VERSION)
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/$(PKG_NAME)_$(PKG_SOURCE_VERSION)
PKG_MD5SUM:=beae2529f759f6b3bf3f4969a19c2e9d6f0c503edcb2de4a61d1428519fcb3b0
PKG_LICENSE:=Boost Software License <http://www.boost.org/users/license.html>
PKG_MAINTAINER:=Carlos M. Ferreira <carlosmf.pt@gmail.com>

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

define Package/boost/description
This package provides the Boost v1.63 libraries.
Boost is a set of free, peer-reviewed, portable C++ source libraries.

-----------------------------------------------------------------------------
|                                Warning                                    |
| In order to build all of the Boost Libraries, it is necessary             |
| to use, at least, GCC version 5 (C++14 support) and, it is necessary to   |
| compile the kernel with Full Language Support.                            |
| Without these requirerements, the following libs will not be available:   |
| - Boost.Locale                                                            |
| - Boost.Coroutine2                                                        |
| - Boost.Fiber                                                             |
| Also, due to hardware contraints, the following libs and those that are   |
|   dependent, are disabled for some Targets.                               |
| - Boost.Context                                                           |
|   - Disabled for -> avr32, octeon and netlogic.                           |
| - Boost.Fiber                                                             |
|   - Disabled for -> ar7, rb532, brcm63xx.smp, brcm63xx, brcm47xx,         |
|                     brcm47xx.legacy, brcm2708_bcm2708, au1000, ath25,     |
|                     adm8668 and adm5120.                                  |
-----------------------------------------------------------------------------

This package provides the following run-time libraries:
 - atomic
 - chrono
 - container
 - context
 - coroutine (Deprecated - use Coroutine2)
 - - coroutine2 (Requires GCC v5 or newer)
 - date_time
 - exception
 - filesystem
 - fiber (Requires GCC v5 or newer)
 - graph
 - - graph-parallel
 - iostreams
 - locale (Requires kernel being compiled with full language support)
 - log
 - math
 - program_options
 - python
 - python3
 - random
 - regex
 - serialization
 - signals
 - system
 - thread
 - timer
 - wave

There are many more header-only libraries supported by Boost.
See more at http://www.boost.org/doc/libs/1_63_0/
endef

PKG_BUILD_DEPENDS:=boost/host PACKAGE_python:python PACKAGE_python3:python3

BOOST_LIBS =

define Package/boost-libs
$(call Package/boost/Default)
  TITLE+= (all libs)
  DEPENDS+= $(BOOST_DEPENDS)
  HIDDEN:=1
endef

define Package/boost-libs/description
 This meta package contains only dependencies to the other libraries from
 the boost libraries collection.
endef

# Create a meta-package of dependent libraries (for ALL)
define Package/boost-libs/install
  true
endef

define Package/boost/install
  true
endef

define Package/boost
  $(call Package/boost/Default)
  TITLE+= packages
endef

define Package/boost/config
	menu "Select Boost Options"
		depends on PACKAGE_boost
		comment "Boost compilation options."

		choice
			prompt "Compile Boost libraries."
				default boost-static-and-shared-libs
				help
					Choose which version to compile.
					-> Shared:
						- Only Shared libs will be compiled.
					-> Static:
						- Only Static libs will be compiled.
					-> Both:
						- Both Static and Shared libs will be compiled.

			config boost-shared-libs
				bool "Shared"
			
			config boost-static-libs
				bool "Static"
			
			config boost-static-and-shared-libs
				bool "Both"
		endchoice

		choice
			prompt "Selects Boost Runtime linkage."
			default boost-runtime-shared
			help
				Choose which C and C++ runtimes to use:
				-> Use Shared runtimes.
				-> Use Static runtimes.
					- Not available if Shared libs are to be built.
				-> Use both runtimes.
					- Not available if Shared libs are to be built.
					- Two separate versions of Boost are built, linking each to a different runtime. 
					- This option requires "Use tagged names" option to be active.

			config boost-runtime-shared
				bool "Shared"

			config boost-runtime-static
				depends on @(!boost-shared-libs&&!boost-static-and-shared-libs)
				bool "Static"		    	

			config boost-runtime-static-and-shared
				depends on @(boost-use-name-tags&&!boost-shared-libs&&!boost-static-and-shared-libs)
				bool "Both"
		endchoice

		choice
			prompt "Select a Variant."
			default boost-variant-release
			help
				Chooses which boost variant should be selected:
				-> Release: Optimizes Boost for release.
					- Optimization: Speed;  Debug Symbols: Off; Inlining: Full; Runtime Debugging: Off.
				-> Debug: 
					- Optimization: Off; Debug Symbols: On; Inlining: Off; Runtime Debugging: On.
				-> Profile:
					- Profiling: On;  Debug Symbols: On.

			config boost-variant-release
				bool "Release"

			config boost-variant-debug
				bool "Debug"

			config boost-variant-profile
				bool "Profile"
		endchoice

		config boost-use-name-tags
			bool "Use tagged names."
			help 
				Add name tags the lib files, to diferentiate each library version:
				  "-mt" for multi-threading.
				  "-d" for debugging.
				  "-s" for runtime static link".
				Might break compatibility with libraries that expect boost libs with default names.
			default n

		config boost-single-thread
			depends on @boost-use-name-tags
			bool "Single thread Support."
			help 
				Compile Boost libraries in single-thread mode.
			default n
			    
		config boost-build-type-complete
			depends on @boost-use-name-tags
			bool "Complete Boost Build."
			help 
				Builds both release and debug libs. It will take much longer to compile.
			default n
	endmenu

	menu "Select Boost libraries"
		depends on PACKAGE_boost
		comment "Libraries"

		config boost-libs-all
			bool "Include all Boost libraries."
			default m if ALL
			select PACKAGE_boost-container
			select PACKAGE_boost-date_time
			select PACKAGE_boost-iostreams
			select PACKAGE_boost-math
			select PACKAGE_boost-program_options
			select PACKAGE_boost-serialization
			select PACKAGE_boost-signals
			select PACKAGE_boost-regex
			select PACKAGE_boost-graph if PACKAGE_boost-regex
			select PACKAGE_boost-system
			select PACKAGE_boost-atomic if PACKAGE_boost-system
			select PACKAGE_boost-chrono if PACKAGE_boost-system
			select PACKAGE_boost-random if PACKAGE_boost-system
			select PACKAGE_boost-filesystem if PACKAGE_boost-system
			select PACKAGE_boost-locale if PACKAGE_boost-system
			select PACKAGE_boost-timer if PACKAGE_boost-chrono
			select PACKAGE_boost-thread if PACKAGE_boost-chrono&&PACKAGE_boost-atomic
			select PACKAGE_boost-context if PACKAGE_boost-chrono&&PACKAGE_boost-thread
			select PACKAGE_boost-coroutine if PACKAGE_boost-context
			select PACKAGE_boost-fiber if boost-coroutine2
			select PACKAGE_boost-log if PACKAGE_boost-chrono&&PACKAGE_boost-date_time&&PACKAGE_boost-thread&&PACKAGE_boost-filesystem&&PACKAGE_boost-regex
			select PACKAGE_boost-wave if PACKAGE_boost-date_time&&PACKAGE_boost-thread&&PACKAGE_boost-filesystem
			select PACKAGE_boost-python
			select PACKAGE_boost-python3
			select boost-test-pkg if PACKAGE_boost-system&&PACKAGE_boost-timer
			select boost-coroutine2 if PACKAGE_boost-coroutine
			select boost-graph-parallel if PACKAGE_boost-graph
			

		config boost-test-pkg
			depends on PACKAGE_boost-system&&PACKAGE_boost-timer
			bool "Boost test package."
			default m if ALL
			select PACKAGE_boost-test

		config boost-coroutine2
			depends on !@GCC_VERSION_4_8&&PACKAGE_boost-coroutine
			bool "Boost couroutine2 support."
			default m if ALL

		config boost-graph-parallel
			depends on PACKAGE_boost-graph
			bool "Boost parallel graph support."
			default m if ALL

		$(foreach lib,$(BOOST_LIBS), \
			config PACKAGE_boost-$(lib)
			prompt "Boost $(lib) library."
			default m if ALL
			$(if $(findstring graph,$(lib)),depends on PACKAGE_boost-regex,)\
			$(if $(findstring atomic,$(lib)),depends on PACKAGE_boost-system,)\
			$(if $(findstring chrono,$(lib)),depends on PACKAGE_boost-system,)\
			$(if $(findstring random,$(lib)),depends on PACKAGE_boost-system,)\
			$(if $(findstring filesystem,$(lib)),depends on PACKAGE_boost-system,)\
			$(if $(findstring locale,$(lib)),depends on PACKAGE_boost-system&&BUILD_NLS,)\
			$(if $(findstring timer,$(lib)),depends on PACKAGE_boost-chrono,)\
			$(if $(findstring thread,$(lib)),depends on PACKAGE_boost-chrono&&PACKAGE_boost-atomic,)\
			$(if $(findstring context,$(lib)),depends on PACKAGE_boost-chrono&&PACKAGE_boost-thread&&@(!TARGET_avr32&&!TARGET_octeon&&!TARGET_netlogic),)\
			$(if $(findstring coroutine,$(lib)),depends on PACKAGE_boost-context,)\
			$(if $(findstring fiber,$(lib)),depends on @boost-coroutine2&&@(!TARGET_ar7&&!TARGET_rb532&&!TARGET_brcm63xx_smp&&!TARGET_brcm63xx&&!TARGET_brcm47xx&&!TARGET_brcm47xx_legacy&&!TARGET_brcm2708_bcm2708&&!TARGET_au1000&&!TARGET_ath25&&!TARGET_adm8668&&!TARGET_adm5120),)\
			$(if $(findstring log,$(lib)),depends on PACKAGE_boost-chrono&&PACKAGE_boost-date_time&&PACKAGE_boost-thread&&PACKAGE_boost-filesystem&&PACKAGE_boost-regex,)\
			$(if $(findstring wave,$(lib)),depends on PACKAGE_boost-date_time&&PACKAGE_boost-thread&&PACKAGE_boost-filesystem,)\
			$(if $(findstring python,$(lib)),depends on PACKAGE_$(lib),)
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
# 2: dependencies on other boost libraries (short name) - Deprecated
# 3: dependencies on other packages
# 4: conditional/inward dependencies
define DefineBoostLibrary

  BOOST_DEPENDS+= +$(if $(4),$(4):boost-$(1),boost-$(1))
  PKG_CONFIG_DEPENDS+= CONFIG_PACKAGE_boost-$(1)

  BOOST_LIBS+= $(1)

  define Package/boost-$(1)
    $(call Package/boost/Default)
    TITLE+= ($(1))
    DEPENDS+= $(3) $(if $(4),@$(4),)
    HIDDEN:=1
  endef

  define Package/boost-$(1)/description
   This package contains the Boost $(1) library.
  endef
endef


## If you are thinking in making changes to the following list, for some reason, the order of what follows matters.
$(eval $(call DefineBoostLibrary,container,,,))
$(eval $(call DefineBoostLibrary,date_time,,,))
$(eval $(call DefineBoostLibrary,iostreams,,+zlib,))
$(eval $(call DefineBoostLibrary,math,,,))
$(eval $(call DefineBoostLibrary,program_options,,,))
$(eval $(call DefineBoostLibrary,serialization,,,))
$(eval $(call DefineBoostLibrary,signals,,,))

$(eval $(call DefineBoostLibrary,regex,,,))
$(eval $(call DefineBoostLibrary,graph,,,))

$(eval $(call DefineBoostLibrary,system,,,))
$(eval $(call DefineBoostLibrary,atomic,,,))
$(eval $(call DefineBoostLibrary,chrono,,,))
$(eval $(call DefineBoostLibrary,random,,,))
$(eval $(call DefineBoostLibrary,filesystem,,,))
$(eval $(call DefineBoostLibrary,locale,,$(ICONV_DEPENDS),BUILD_NLS))
$(eval $(call DefineBoostLibrary,timer,,,))
$(eval $(call DefineBoostLibrary,thread,,,))
$(eval $(call DefineBoostLibrary,context,,,))
$(eval $(call DefineBoostLibrary,coroutine,,,))
$(eval $(call DefineBoostLibrary,fiber,,,))
$(eval $(call DefineBoostLibrary,log,,,))
$(eval $(call DefineBoostLibrary,wave,,,))
$(eval $(call DefineBoostLibrary,python,,,PACKAGE_python))
$(eval $(call DefineBoostLibrary,python3,,,PACKAGE_python3))

#$(eval $(call DefineBoostLibrary,mpi,,)) # OpenMPI does no exist in OpenWRT at this time.
#$(eval $(call DefineBoostLibrary,exception,,))


define Host/Compile
	# b2 does not provide a configure-script nor a Makefile
	( cd $(HOST_BUILD_DIR)/tools/build/src/engine ; ./build.sh gcc )
endef

CONFIGURE_PREFIX:=$(PKG_INSTALL_DIR)
TARGET_LDFLAGS += -pthread -lrt

TARGET_CFLAGS += \
	$(if $(CONFIG_SOFT_FLOAT),-DBOOST_NO_FENV_H) -fPIC

EXTRA_CXXFLAGS += $(if $(CONFIG_GCC_VERSION_4_8),-std=gnu++11,-std=gnu++14)

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

comma := ,


define Build/Compile
	$(info Selected Boost API $(BOOST_ABI) for architecture $(ARCH) and cpu $(CPU_TYPE) $(CPU_SUBTYPE))
	( cd $(PKG_BUILD_DIR) ; \
		echo "using gcc : $(ARCH) : $(GNU_TARGET_NAME)-gcc : <compileflags>\"$(TARGET_CFLAGS)\" <cxxflags>\"$(TARGET_CXXFLAGS) $(EXTRA_CXXFLAGS)\" <linkflags>\"$(TARGET_LDFLAGS)\" ;" > tools/build/src/user-config.jam ; \
		$(if $(CONFIG_PACKAGE_boost-python3), \
			echo "using python : 3.6 : : $(STAGING_DIR)/usr/include/python3.6/ ;" >> \
				tools/build/src/user-config.jam; \
		) \
		$(if $(CONFIG_PACKAGE_boost-python), \
			echo "using python : 2.7 : : $(STAGING_DIR)/usr/include/python2.7/ ;" >> \
				tools/build/src/user-config.jam; \
		) \
		b2 \
			$(CONFIGURE_ARGS) \
			--ignore-site-config \
			--toolset=gcc-$(ARCH) abi=$(BOOST_ABI) \
			--disable-long-double \
			$(if $(CONFIG_boost-variant-release), variant=release,) \
			$(if $(CONFIG_boost-variant-debug), variant=debug,) \
			$(if $(CONFIG_boost-variant-profile), variant=profile,) \
			$(if $(CONFIG_boost-use-name-tags),--layout=tagged,--layout=system) \
			$(if $(CONFIG_boost-build-type-complete),--build-type=complete,--build-type=minimal) \
			$(if $(CONFIG_boost-shared-libs),link=shared,) \
			$(if $(CONFIG_boost-static-libs),link=static,) \
			$(if $(CONFIG_boost-static-and-shared-libs),link=static$(comma)shared,) \
			$(if $(CONFIG_boost-runtime-shared),runtime-link=shared,) \
			$(if $(CONFIG_boost-runtime-static),runtime-link=static,) \
			$(if $(CONFIG_boost-runtime-static-and-shared),runtime-link=shared$(comma)static,) \
			$(if $(CONFIG_boost-single-thread),threading=single,) \
			threading=multi \
			--without-mpi \
			$(if $(CONFIG_boost-coroutine2),,--without-coroutine2) \
			$(if $(CONFIG_boost-graph-parallel),,--without-graph_parallel) \
			$(if $(CONFIG_PACKAGE_boost-test),,--without-test) \
			$(foreach lib,$(BOOST_LIBS), \
				$(if $(findstring python,$(lib)), \
					$(if $(or $(CONFIG_PACKAGE_boost-python),$(CONFIG_PACKAGE_boost-python3)),,--without-python), \
					$(if $(CONFIG_PACKAGE_boost-$(lib)),,--without-$(lib))) \
			) \
			$(if $(CONFIG_PACKAGE_boost-python),python=2.7,) \
			$(if $(CONFIG_PACKAGE_boost-python3),python=3.6,) \
			$(if $(CONFIG_PACKAGE_boost-locale),boost.locale.iconv=on -sICONV_PATH=$(ICONV_PREFIX) boost.locale.posix=$(if $(USE_MUSL),on,off), \
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

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) -v $(PKG_INSTALL_DIR)/lib/*.a $(1)/usr/lib/ # copies all compiled archive files
	$(FIND) $(PKG_INSTALL_DIR)/lib/ -name '*.so*' -exec $(CP) {} $(1)/usr/lib/ \; # copies all the shared objects files
endef

define Host/Install
	$(INSTALL_DIR) \
		$(STAGING_DIR_HOSTPKG)/bin

	$(CP) \
		$(HOST_BUILD_DIR)/tools/build/src/engine/bin.*/b2 \
		$(STAGING_DIR_HOSTPKG)/bin/
endef

define Package/boost/Default/install
	$(INSTALL_DIR) \
		$(1)/usr/lib

	$(FIND) \
		$(PKG_INSTALL_DIR)/lib/ -name 'libboost_$(2).so*' -exec $(CP) {} $(1)/usr/lib/ \;
	$(FIND) \
		$(PKG_INSTALL_DIR)/lib/ -name 'libboost_$(2)_*.so*' -exec $(CP) {} $(1)/usr/lib/ \;
endef

define Package/boost-test/install
		$(INSTALL_DIR) \
			$(1)/usr/lib

		$(FIND) \
			$(PKG_INSTALL_DIR)/lib/ -name 'libboost_unit_test_framework*.so*' -exec $(CP) {} $(1)/usr/lib/ \;
		
		$(FIND) \
			$(PKG_INSTALL_DIR)/lib/ -name 'libboost_prg_exec_monitor*.so*' -exec $(CP) {} $(1)/usr/lib/ \;	
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
