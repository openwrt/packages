#
# Copyright (C) 2009-2020 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=erlang
PKG_VERSION:=28.0.3
PKG_RELEASE:=1

PKG_SOURCE:=otp_src_$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/erlang/otp/releases/download/OTP-$(PKG_VERSION)
PKG_HASH:=0cdf3b44e327439ea6677e61e06f28a0f82ea080af2dcbd665bc5a945b167012

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=
PKG_CPE_ID:=cpe:/a:erlang:erlang

PKG_BUILD_DEPENDS:=erlang/host openssl unixodbc/host
PKG_BUILD_FLAGS:=no-mips16
PKG_ASLR_PIE:=0

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/otp_src_$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/otp_src_$(PKG_VERSION)

HOST_BUILD_PARALLEL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/erlang/config
config ERLANG_JIT
    bool
    depends on (x86_64||aarch64)
    default y

config ERLANG_SCTP
    bool "SCTP protocol support"
    default n
endef

## Host
HOST_CONFIGURE_ARGS += \
	--without-wx \
	--with-ssl="$(STAGING_DIR_HOST)" \
	--without-javac

## Target
CONFIGURE_ARGS += \
	--with-odbc \
	--without-javac \
	--enable-shared-zlib \
	--enable-dynamic-ssl-lib \
	--$(if $(CONFIG_ERLANG_JIT),enable,disable)-jit \
	--$(if $(CONFIG_ERLANG_SCTP),enable,disable)-sctp

CONFIGURE_VARS += \
	SHLIB_LD="$(TARGET_CC)" \
	TARGET_ARCH="$(TARGET_ARCH)" \
	erl_xcomp_sysroot="$(STAGING_DIR)"

define Package/erlang/Default
  SUBMENU:=Erlang
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Erlang/OTP programming language
  URL:=https://www.erlang.org/
endef

define Package/erlang/Default/description
 Erlang/OTP is a general-purpose programming language and runtime environment.
endef

define Package/erlang
$(call Package/erlang/Default)
  DEPENDS+= +libncurses +librt +zlib +ERLANG_SCTP:libsctp +ERLANG_JIT:libstdcpp
  PROVIDES:= erlang-erts erlang-kernel erlang-stdlib
endef

define Package/erlang/description
$(call Package/erlang/Default/description)
 This package contains the runtime implementation and a minimal set of modules
 (erts, kernel & stdlib).
endef

define Package/erlang-asn1
$(call Package/erlang/Default)
  TITLE:=Abstract Syntax Notation One (ASN.1) support
  DEPENDS+= +erlang
endef

define Package/erlang-asn1/description
$(call Package/erlang/Default/description)
 This package provides Abstract Syntax Notation One (ASN.1) support.
endef

define Package/erlang-compiler
$(call Package/erlang/Default)
  TITLE:=Byte code compiler
  DEPENDS+= +erlang
endef

define Package/erlang-compiler/description
$(call Package/erlang/Default/description)
 This package provides a byte code compiler for Erlang which produces highly
 compact code.
endef

define Package/erlang-crypto
$(call Package/erlang/Default)
  TITLE:=Cryptography support
  DEPENDS+= +erlang +libopenssl
endef

define Package/erlang-crypto/description
$(call Package/erlang/Default/description)
 This package provides functions for computation of message digests,
 and encryption and decryption functions.
endef

define Package/erlang-diameter
$(call Package/erlang/Default)
  TITLE:=Diameter protocol
  DEPENDS+= +erlang
endef

define Package/erlang-diameter/description
$(call Package/erlang/Default/description)
 This package implements Diameter protocol as defined by RFC 6733.
endef

define Package/erlang-eldap
$(call Package/erlang/Default)
  TITLE:=Erlang LDAP Client
  DEPENDS+= +erlang +erlang-asn1
endef

define Package/erlang-eldap/description
$(call Package/erlang/Default/description)
 This package provides client api to the Lightweight Directory Access Protocol
 (LDAP).
endef

define Package/erlang-erl-interface
$(call Package/erlang/Default)
  TITLE:=Erlang erl_interface support
  DEPENDS+= +erlang
endef

define Package/erlang-erl-interface/description
$(call Package/erlang/Default/description)
 This package provides support for Erlang interoperability with other languages.
endef

define Package/erlang-ftp
$(call Package/erlang/Default)
  TITLE:=Erlang FTP Client
  DEPENDS+= +erlang +erlang-runtime-tools
endef

define Package/erlang-ftp/description
$(call Package/erlang/Default/description)
 This package implements File Transfer Protocol client.
endef

define Package/erlang-inets
$(call Package/erlang/Default)
  TITLE:=Internet clients and servers
  DEPENDS+= +erlang +erlang-public-key
endef

define Package/erlang-inets/description
$(call Package/erlang/Default/description)
 This package provides an HTTP client and server.
endef

define Package/erlang-mnesia
$(call Package/erlang/Default)
  TITLE:=Distributed database
  DEPENDS+= +erlang
endef

define Package/erlang-mnesia/description
$(call Package/erlang/Default/description)
 This package provides a distributed DataBase Management System (DBMS),
 appropriate for telecommunications applications and other Erlang applications
 which require continuous operation and exhibit soft real-time properties.
endef

define Package/erlang-odbc
$(call Package/erlang/Default)
  TITLE:=Erlang ODBC application
  DEPENDS+= +erlang +libodbc
endef

define Package/erlang-odbc/description
$(call Package/erlang/Default/description)
 This package provides an Erlang interface to communicate with relational
 SQL-databases.
endef

define Package/erlang-os-mon
$(call Package/erlang/Default)
  TITLE:=OS Monitoring Application
  DEPENDS+= +erlang +erlang-sasl
endef

define Package/erlang-os-mon/description
$(call Package/erlang/Default/description)
 This package provides the following services:
  cpu_sup CPU load and utilization supervision
  memsup Memory supervision
endef

define Package/erlang-parsetools
$(call Package/erlang/Default)
  TITLE:=A set of parsing and lexical analysis tools
  DEPENDS+= +erlang
endef

define Package/erlang-parsetools/description
$(call Package/erlang/Default/description)
 This package includes the following tools:
  yecc, LALR-1 Parser Generator.
  leex, Lexical analyzer generator for Erlang.
endef

define Package/erlang-public-key
$(call Package/erlang/Default)
  TITLE:=Public Key support
  DEPENDS+= +erlang +erlang-asn1
endef

define Package/erlang-public-key/description
$(call Package/erlang/Default/description)
 This package provides functions to handle public-key infrastructure.
endef

define Package/erlang-reltool
$(call Package/erlang/Default)
  TITLE:=Erlang reltool support
  DEPENDS+= +erlang +erlang-tools +erlang-sasl
endef

define Package/erlang-reltool/description
$(call Package/erlang/Default/description)
 This package provides support for release management.
endef

define Package/erlang-runtime-tools
$(call Package/erlang/Default)
  TITLE:=Low-profile debugging/tracing tools
  DEPENDS+= +erlang +erlang-mnesia
endef

define Package/erlang-runtime-tools/description
$(call Package/erlang/Default/description)
 This package provides low footprint tracing/debugging tools suitable
 for inclusion in a production system.
endef

define Package/erlang-sasl
$(call Package/erlang/Default)
  TITLE:=The System Architecture Support Libraries
  DEPENDS+= +erlang
endef

define Package/erlang-sasl/description
$(call Package/erlang/Default/description)
 The SASL application provides support for:
  Error logging.
  Alarm handling.
  Release handling.
  Report browsing.
endef

define Package/erlang-snmp
$(call Package/erlang/Default)
  TITLE:=Simple Network Management Protocol (SNMP) support
  DEPENDS+= +erlang +erlang-asn1 +erlang-runtime-tools
endef

define Package/erlang-snmp/description
$(call Package/erlang/Default/description)
 This package provides Simple Network Management Protocol (SNMP) support
 including a MIB compiler and tools for creating SNMP agents.
endef

define Package/erlang-ssh
$(call Package/erlang/Default)
  TITLE:=Secure Shell (SSH) support
  DEPENDS+= +erlang +erlang-public-key +erlang-runtime-tools
endef

define Package/erlang-ssh/description
$(call Package/erlang/Default/description)
 This package provides an implementation of the Secure Shell protocol,
 with SSH & SFTP support.
endef

define Package/erlang-ssl
$(call Package/erlang/Default)
  TITLE:=Secure Sockets Layer (SSL) support
  DEPENDS+= +erlang +erlang-crypto +erlang-inets +erlang-runtime-tools
endef

define Package/erlang-ssl/description
$(call Package/erlang/Default/description)
 This package provides support for secure communication over sockets.
endef

define Package/erlang-syntax-tools
$(call Package/erlang/Default)
  TITLE:=Abstract Erlang syntax trees handling support
  DEPENDS+= +erlang +erlang-compiler
endef

define Package/erlang-syntax-tools/description
$(call Package/erlang/Default/description)
 This package provides support for handling abstract Erlang syntax trees.
endef

define Package/erlang-tftp
$(call Package/erlang/Default)
  TITLE:=Trivial FTP application
  DEPENDS+= +erlang
endef

define Package/erlang-tftp/description
$(call Package/erlang/Default/description)
 This package implements the following IETF standards:
  RFC 1350, The TFTP Protocol (revision 2).
  RFC 2347, TFTP Option Extension.
  RFC 2348, TFTP Blocksize Option.
  RFC 2349, TFTP Timeout Interval and Transfer Size Options.
endef

define Package/erlang-tools
$(call Package/erlang/Default)
  TITLE:=Erlang tools support
  DEPENDS+= +erlang +erlang-runtime-tools +erlang-compiler
endef

define Package/erlang-tools/description
$(call Package/erlang/Default/description)
 This package provides support for misc tools.
endef

define Package/erlang-xmerl
$(call Package/erlang/Default)
  TITLE:=XML 1.0 support
  DEPENDS+= +erlang
endef

define Package/erlang-xmerl/description
$(call Package/erlang/Default/description)
 This package provides functions for exporting XML data to an external format.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		MAKEFLAGS=$(PKG_JOBS) \
		INSTALL_PREFIX="$(PKG_INSTALL_DIR)" \
		noboot install
endef

define Package/erlang/install
	$(INSTALL_DIR) $(1)/usr/bin
	for f in epmd erl erlc escript run_erl; do \
		$(CP) $(PKG_INSTALL_DIR)/usr/bin/$$$$f $(1)/usr/bin/ ; \
	done
	$(INSTALL_DIR) $(1)/usr/lib/erlang/bin
	for f in epmd erl erlc escript run_erl start start.boot start.script start_clean.boot start_erl start_sasl.boot no_dot_erlang.boot to_erl; do \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/erlang/bin/$$$$f $(1)/usr/lib/erlang/bin/ ; \
	done
	$(INSTALL_DIR) $(1)/usr/lib/erlang/lib
	for m in erts kernel sasl stdlib; do \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/erlang/lib/$$$$m-* $(1)/usr/lib/erlang/lib/ ; \
		rm -rf $(1)/usr/lib/erlang/lib/$$$$m-*/examples ; \
		rm -rf $(1)/usr/lib/erlang/lib/$$$$m-*/src ; \
	done
	$(INSTALL_DIR) $(1)/usr/lib/erlang
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/erlang/erts-* $(1)/usr/lib/erlang/
	rm -rf $(1)/usr/lib/erlang/erts-*/{doc,include,lib,man,src}
	rm -rf $(1)/usr/lib/erlang/erts-*/bin/*.src
	$(INSTALL_DIR) $(1)/usr/lib/erlang/releases
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/erlang/releases/* $(1)/usr/lib/erlang/releases/
	$(SED) 's,%ERL_ROOT%,/usr/lib/erlang,g' \
		$(1)/usr/lib/erlang/releases/RELEASES.src
	mv -f $(1)/usr/lib/erlang/releases/RELEASES.src \
		$(1)/usr/lib/erlang/releases/RELEASES
	for f in bin/erl bin/start erts-*/bin/erl erts-*/bin/start; do \
		$(SED) 's,^\(ROOTDIR\)=.*,\1=/usr/lib/erlang,g' \
			$(1)/usr/lib/erlang/$$$$f ; \
	done
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/erl_interface/obj/*/*.a $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/lib/erl_interface/include/*.h $(1)/usr/include/
endef

define BuildModule

  define Package/erlang-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/lib/erlang/lib
	for m in $(2); do \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/erlang/lib/$$$$$$$$m-* $$(1)/usr/lib/erlang/lib/ ; \
		rm -rf $$(1)/usr/lib/erlang/lib/$$$$$$$$m-*/{examples,priv/obj,src} ; \
	done
  endef

  $$(eval $$(call BuildPackage,erlang-$(1)))

endef


$(eval $(call HostBuild))
$(eval $(call BuildPackage,erlang))
$(eval $(call BuildModule,asn1,asn1))
$(eval $(call BuildModule,compiler,compiler))
$(eval $(call BuildModule,crypto,crypto))
$(eval $(call BuildModule,diameter,diameter))
$(eval $(call BuildModule,eldap,eldap))
$(eval $(call BuildModule,erl-interface,erl_interface))
$(eval $(call BuildModule,ftp,ftp))
$(eval $(call BuildModule,inets,inets))
$(eval $(call BuildModule,mnesia,mnesia))
$(eval $(call BuildModule,odbc,odbc))
$(eval $(call BuildModule,os-mon,os-mon))
$(eval $(call BuildModule,parsetools,parsetools))
$(eval $(call BuildModule,public-key,public_key))
$(eval $(call BuildModule,reltool,reltool))
$(eval $(call BuildModule,runtime-tools,runtime_tools))
$(eval $(call BuildModule,sasl,sasl))
$(eval $(call BuildModule,snmp,snmp))
$(eval $(call BuildModule,ssh,ssh))
$(eval $(call BuildModule,ssl,ssl))
$(eval $(call BuildModule,syntax-tools,syntax_tools))
$(eval $(call BuildModule,tftp,tftp))
$(eval $(call BuildModule,tools,tools))
$(eval $(call BuildModule,xmerl,xmerl))
