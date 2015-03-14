#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl
PKG_VERSION:=5.20.2
PKG_RELEASE:=1

PKG_SOURCE_URL:=ftp://ftp.cpan.org/pub/CPAN/src/5.0 \
		http://www.cpan.org/src/5.0/perl-5.20.0.tar.gz \
		ftp://ftp.mpi-sb.mpg.de/pub/perl/CPAN/src/5.0 \
		http://ftp.mpi-sb.mpg.de/pub/perl/CPAN/src/5.0 \
		ftp://ftp.gmd.de/mirrors/CPAN/src/5.0 \
		http://ftp5.gwdg.de/pub/languages/perl/CPAN/src/ \
		ftp://ftp.funet.fi/pub/languages/perl/CPAN/src/5.0 \
		http://ftp.funet.fi/pub/languages/perl/CPAN/src/5.0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MD5SUM:=81b17b9a4e5ee18e54efe906c9bf544d

PKG_LICENSE:=GPL-1.0+ Artistic-1.0-Perl
PKG_LICENSE_FILES:=Copying Artistic README
PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>

# Build settings
PKG_BUILD_DIR:=$(BUILD_DIR)/perl/$(PKG_NAME)-$(PKG_VERSION)
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/perl/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL:=1
PKG_BUILD_DEPENDS:=perl/host
PKG_BUILD_PARALLEL:=1
HOST_BUILD_PARALLEL:=1

# Variables used during configuration/build
HOST_PERL_PREFIX:=$(STAGING_DIR_HOST)/usr
ifneq ($(CONFIG_USE_GLIBC),)
	EXTRA_LIBS:=bsd
	EXTRA_LIBDIRS:=$(STAGING_DIR)/lib
endif

# Filter -g3, it will break Compress-Raw-Zlib
TARGET_CFLAGS_PERL:=$(patsubst -g3,-g,$(TARGET_CFLAGS))
TARGET_CPPFLAGS_PERL:=$(patsubst -g3,-g,$(TARGET_CPPFLAGS))

# Handle threading
ifdef CONFIG_PERL_THREADS
	PERL_CONFIG_SUFFIX:=-mt

	# uclibc doesn't provide crypt_r(). Enable crypt() usage for glibc builds only
	ifdef CONFIG_USE_GLIBC
		CRYPT_R_PROTO:=REENTRANT_PROTO_B_CCS
		CRYPT:=define
	else
		CRYPT_R_PROTO:=0
		CRYPT:=undef
	endif
endif

# A list of disabled tests
# ExtUtils tests are disabled for now as we don't support building
# native extensions on the target machine at the moment
PERL_DISABLEDTESTS:=cpan/ExtUtils-Constant cpan/ExtUtils-MakeMaker
# We're on Linux, so don't even package them
PERL_DISABLEDTESTS+=cpan/Win32API-File cpan/Win32 ext/VMS-DCLsym ext/VMS-Filespec ext/VMS-Stdio ext/Win32CORE
# NDBM and ODBM not supported
PERL_DISABLEDTESTS+=ext/NDBM_File ext/ODBM_File


include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include perlmod.mk

define Package/perl
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=The Perl intepreter
  URL:=http://www.perl.com/
  DEPENDS:=+USE_GLIBC:libbsd +PERL_THREADS:libpthread
endef

define Package/perl/description
  Perl is a stable, cross platform programming language.
  It is used for mission critical projects in the public and private sectors
  and is widely used to program web applications of all needs.
endef

define Package/perl/config
	source "$(SOURCE)/Config.in"
endef

# Static host perl
define Host/Configure
	( cd $(HOST_BUILD_DIR); ./Configure -der -Uusedl -Duserelocatableinc -Dprefix=$(HOST_PERL_PREFIX) )
endef

define Host/Install
	( cd $(HOST_BUILD_DIR); ./miniperl installperl )
	$(INSTALL_DIR) $(HOST_PERL_PREFIX)/bin/
	$(CP) $(HOST_BUILD_DIR)/generate_uudmap $(HOST_PERL_PREFIX)/bin/
	
	# Link any possibly installed static extension in
	$(MAKE) -C $(HOST_BUILD_DIR)/relink clean || true
	( cd $(HOST_BUILD_DIR)/relink && $(HOST_PERL_PREFIX)/bin/perl Makefile.PL )
	$(call perlmod/host/relink,$(HOST_BUILD_DIR)/relink)
endef

# Target perl
define Build/Configure
	sed \
		-e 's!%%CC%%!$(TARGET_CC)!g' \
		-e 's!%%CFLAGS%%!$(TARGET_CFLAGS_PERL) $(TARGET_CPPFLAGS_PERL)!g' \
		-e 's!%%CPP%%!$(TARGET_CROSS)gcc -E!g' \
		-e 's!%%AR%%!$(TARGET_CROSS)ar!g' \
		-e 's!%%LD%%!$(TARGET_CROSS)gcc!g' \
		-e 's!%%LDFLAGS%%!-rdynamic $(TARGET_LDFLAGS)!g' \
		-e 's!%%LIBDIRS%%!$(STAGING_DIR)/lib $(STAGING_DIR)/usr/lib!g' \
		-e 's!%%INCDIRS%%!$(STAGING_DIR)/include $(STAGING_DIR)/usr/include!g' \
		-e 's!%%EXTRA_PERLLIBS%%!$(EXTRA_LIBS:%=-l%)!g' \
		-e 's!%%EXTRA_PERLLIBDIRS%%!$(EXTRA_LIBDIRS:%=-L%)!g' \
		-e 's!%%IPV6%%!$(if $($(CONFIG_IPV6)),define,undef)!g' \
		-e 's!%%HOSTMINIPERL%%!$(HOST_PERL_PREFIX)/bin/perl!g' \
		-e 's!%%CRYPT_R_PROTO%%!$(CRYPT_R_PROTO)!g' \
		-e 's!%%CRYPT%%!$(CRYPT)!g' \
		-e 's!%%HOSTGENERATE%%!$(HOST_PERL_PREFIX)/bin/generate_uudmap!g' \
		files/config.sh-$(patsubst i386,i486,$(ARCH))$(PERL_CONFIG_SUFFIX).in \
		> $(PKG_BUILD_DIR)/config.sh
	(cd $(PKG_BUILD_DIR) && ./Configure -S)
	install -m 0644 $(PKG_BUILD_DIR)/config.h $(PKG_BUILD_DIR)/xconfig.h
endef

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib/perl5/5.20
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/perl5/5.20 $(1)/usr/lib/perl5/
endef

define Package/perl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/perl$(PKG_VERSION) $(1)/usr/bin
	ln -nsf perl$(PKG_VERSION) $(1)/usr/bin/perl
	
	$(INSTALL_DIR) $(1)/usr/lib/perl5/5.20/CORE
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/perl5/5.20/CORE/libperl.so $(1)/usr/lib/perl5/5.20/CORE/
endef


$(eval $(call RequireCommand,rsync, \
	$(PKG_NAME) requires rsync installed on the host-system. \
))

$(eval $(call BuildPackage,perl))
$(eval $(call HostBuild))

-include perlbase.mk

# A helper package that includes all sort of supplementary files for tests
define Package/perl-tests-common
$(call Package/perlbase-template)
TITLE:=Common test support files
DEPENDS:=@PERL_TESTS
endef

define Package/perl-tests-common/install
	$(INSTALL_DIR) $(1)/$(PERL_TESTSDIR)
	$(INSTALL_DIR) $(1)/$(PERL_TESTSDIR)/Porting
	$(INSTALL_DIR) $(1)/$(PERL_TESTSDIR)/regen
	$(INSTALL_DIR) $(1)/usr/lib/perl5/5.20/XS
	$(INSTALL_DIR) $(1)/usr/lib/perl5/5.20/auto/XS
	$(INSTALL_DIR) $(1)/usr/lib/perl5/5.20/unicore
	
	$(CP) $(PKG_BUILD_DIR)/t $(1)/$(PERL_TESTSDIR)
	$(CP) $(PKG_BUILD_DIR)/Porting $(1)/$(PERL_TESTSDIR)
	$(CP) $(PKG_BUILD_DIR)/regen $(1)/$(PERL_TESTSDIR)
	$(CP) $(PKG_BUILD_DIR)/MANIFEST $(1)/$(PERL_TESTSDIR)
	$(CP) $(PKG_BUILD_DIR)/TestInit.pm $(1)/$(PERL_TESTSDIR)
	$(CP) $(PKG_BUILD_DIR)/vutil.c $(1)/$(PERL_TESTSDIR)
	$(CP) $(PKG_BUILD_DIR)/vxs.inc $(1)/$(PERL_TESTSDIR)
	$(CP) $(PKG_BUILD_DIR)/lib/XS $(1)/usr/lib/perl5/5.20/
	$(CP) $(PKG_BUILD_DIR)/lib/auto/XS $(1)/usr/lib/perl5/5.20/auto
	$(CP) $(PKG_BUILD_DIR)/lib/vmsish.pm $(1)/usr/lib/perl5/5.20/
	$(CP) $(PKG_BUILD_DIR)/lib/unicore/TestProp.pl $(1)/usr/lib/perl5/5.20/unicore
	$(CP) files/perl-run_tests.sh $(1)/$(PERL_TESTSDIR)/run_tests.sh
	sed -e 's!%%PERL_DISABLEDTESTS%%!$(PERL_DISABLEDTESTS)!' -i $(1)/$(PERL_TESTSDIR)/run_tests.sh
	$(CP) $(PKG_BUILD_DIR)/config_h.SH $(1)/$(PERL_TESTSDIR)
	$(CP) $(PKG_BUILD_DIR)/perl.h $(1)/$(PERL_TESTSDIR)
endef

$(eval $(call BuildPackage,perl-tests-common))
