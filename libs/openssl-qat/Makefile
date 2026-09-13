#
# Copyright (C) Ian Cooper <iancooper@hotmail.com>
#
# This is free software, licensed under the GNU General Public License v3.
#
#
include $(TOPDIR)/rules.mk

PKG_NAME:=openssl-qat
PKG_VERSION:=0.6.4
PKG_RELEASE:=1

PKG_SOURCE:=v${PKG_VERSION}.tar.gz
PKG_SOURCE_URL:=https://github.com/intel/QAT_Engine/archive/refs/tags/
PKG_HASH:=c5eaf3c5587b7fac8e5256b3431591d91262350eb9ef4b32cd5de09691fc9ee9

PKG_MAINTAINER:=Mark Abe <github@mab.wien>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/QAT_Engine-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=openssl
PKG_FIXUP:=autoreconf
PKG_REMOVE_FILES:=autogen.sh

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/openssl-qat
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=SSL
  TITLE:=Intel Quick Assist OpenSSL Engine
  URL:=https://github.com/intel/QAT_Engine.git
  DEPENDS:= \
	@TARGET_x86_64 \
	+libopenssl \
	+(TARGET_x86_64&&QAT_C2XXX):quickassist-c2xxx \
	+(TARGET_x86_64&&QAT_C3XXX):quickassist-c3xxx
endef

define Package/openssl-qat/description
  Intel Quick Assist hardware acceleration engine for OpenSSL
endef

define Package/openssl-qat/config
 source "$(SOURCE)/Config.in"
endef

#CONFIGURE_ARGS += --with-openssl_install_dir=$(PKG_INSTALL_DIR)/usr 
CONFIGURE_ARGS += --prefix=$(PKG_INSTALL_DIR) 

# quickassist-c2xxx/c3xxx's PKG_BUILD_DIR is wiped by CONFIG_AUTOREMOVE once
# that package finishes building, so point at the copy their Build/InstallDev
# leaves behind in staging_dir (same quickassist/ + build/ layout) instead.
CONFIGURE_ARGS += $(if $(CONFIG_QAT_C3XXX)                            ,--with-qat_dir=$(STAGING_DIR)/usr/icp)
CONFIGURE_ARGS += $(if $(CONFIG_QAT_C2XXX)                            ,--with-qat_dir=$(STAGING_DIR)/usr/icp)

# The QAT1.5/c2xxx (Rangeley/Coleto Creek) driver API predates X25519/X448
# support: its cpa_cy_ec.h has no CpaCyEcMontEdwdsPointMultiplyOpData, so
# qat_ecx.c's hardware-offload path (guarded by OPENSSL_DISABLE_QAT_ECX)
# fails to compile against it. Fall back to the software ECX implementation
# for this driver generation.
CONFIGURE_ARGS += $(if $(CONFIG_QAT_C2XXX)                            ,--disable-qat_ecx)

CONFIGURE_ARGS += $(if $(CONFIG_QAT_ENGINE_DISABLE_RSA)               ,--disable-qat_rsa)
CONFIGURE_ARGS += $(if $(CONFIG_QAT_ENGINE_DISABLE_DSA)               ,--disable-qat_dsa)
CONFIGURE_ARGS += $(if $(CONFIG_QAT_ENGINE_DISABLE_DH)                ,--disable-qat_dh)
CONFIGURE_ARGS += $(if $(CONFIG_QAT_ENGINE_DISABLE_ECDSA)             ,--disable-qat_ecdsa)
CONFIGURE_ARGS += $(if $(CONFIG_QAT_ENGINE_DISABLE_CIPHERS)           ,--disable-qat_ciphers)
CONFIGURE_ARGS += $(if $(CONFIG_QAT_ENGINE_DISABLE_PRF)               ,--disable-qat_prf)
CONFIGURE_ARGS += $(if $(CONFIG_QAT_ENGINE_DISABLE_HKDF)              ,--disable-qat_hkdf)
CONFIGURE_ARGS += $(if $(CONFIG_QAT_ENGINE_ENABLE_GCM_CIPHERS)        ,--enable-qat_gcm)
CONFIGURE_ARGS += $(if $(CONFIG_QAT_ENGINE_ENABLE_SMALL_PACKET)       ,--enable-qat_small_pkt_offload)
CONFIGURE_ARGS += $(if $(CONFIG_QAT_ENGINE_ENABLE_WARNINGS)           ,--enable-qat_warnings)
CONFIGURE_ARGS += $(if $(CONFIG_QAT_ENGINE_ENABLE_DEBUG)              ,--enable-qat_debug)
CONFIGURE_ARGS += $(if $(CONFIG_QAT_ENGINE_ENABLE_QAT_MEM_WARNINGS)   ,--enable-qat_mem_warnings)
CONFIGURE_ARGS += $(if $(CONFIG_QAT_ENGINE_ENABLE_MEM_DEBUG)          ,--enable-qat_mem_debug)
CONFIGURE_ARGS += $(if $(CONFIG_QAT_ENGINE_ENABLE_MULTITHREAD)        ,--enable-multi_thread)
CONFIGURE_ARGS += $(if $(CONFIG_QAT_ENGINE_DISABLE_LENSTRA)           ,--disable-qat_lenstra_protection)
CONFIGURE_ARGS += $(if $(CONFIG_QAT_ENGINE_DISABLE_AUTOINIT_ONFORK)   ,--disable-qat_auto_engine_init_on_fork)
CONFIGURE_ARGS += $(if $(CONFIG_QAT_C2XXX)                            ,--enable-qat16_driver)

# configure's out-of-tree default (-lqat_s) assumes the newer QAT2.0-style
# access-layer library name; our QAT1.5/c2xxx vendor driver builds
# libicp_qa_al_s.so instead. --with-DRIVER=... can't override this: its
# AC_ARG_WITH has an empty action-if-given clause, so the flag is accepted
# but silently has no effect. quickassist-c2xxx's Build/InstallDev instead
# symlinks libqat_s.so -> libicp_qa_al_s.so so the default name resolves.

# configure's AC_CHECK_FILE(/usr/include/qat/icp_sal_versions.h) probes the
# build host's filesystem to tell an in-tree kernel QAT driver from an
# out-of-tree one, which autoconf refuses to do at all when cross compiling.
# We always use the out-of-tree vendor driver (quickassist-c2xxx /
# quickassist-c3xxx), so pre-seed the cache variable instead of probing.
CONFIGURE_VARS += \
	ac_cv_file__usr_include_qat_icp_sal_versions_h="no"

# The QAT1.5/c2xxx libusdm_drv only exports qaeMemFree(NUMA), not the
# "NonZero" variants QAT_Engine otherwise calls. Upstream only defines
# QAT_DISABLE_NONZERO_MEMFREE for its in-tree-driver autodetect path, which
# we bypass above, so set it explicitly for this out-of-tree driver instead.
EXTRA_CFLAGS += $(if $(CONFIG_QAT_C2XXX)                              ,-DQAT_DISABLE_NONZERO_MEMFREE)

MAKE_VARS += \
	CROSS_COMPILE="$(KERNEL_CROSS)" \
	KERNEL_SOURCE_ROOT="$(LINUX_DIR)" \
	PATH_AUTOCNF="include/generated/autoconf.h" \
	WITH_ICP_TARGET="1" 

# OpenWrt's libopenssl (3.x) is built with ENGINESDIR=/usr/lib/engines-3
# (see e.g. libopenssl-afalg/-devcrypto/-padlock, which install there too) -
# ENGINE_by_id() only searches that path by default. engines-1.1 is a
# leftover from an OpenSSL 1.1-era assumption and is never searched by an
# OpenSSL 3.x build, silently breaking ssl_engine qatengine (nginx),
# --engine qatengine (OpenVPN) and similar at runtime.
define Package/openssl-qat/install
	$(INSTALL_DIR) $(1)/usr/lib/engines-3
	$(INSTALL_DIR) $(1)/usr/share/quickassist/QAT_Engine/config
	$(CP) $(PKG_BUILD_DIR)/.libs/qatengine.so $(1)/usr/lib/engines-3
	$(CP) $(PKG_BUILD_DIR)/qatengine.la $(1)/usr/lib/engines-3
	$(CP) $(PKG_BUILD_DIR)/qat/config/c3xxx $(1)/usr/share/quickassist/QAT_Engine/config
endef

$(eval $(call BuildPackage,openssl-qat))
