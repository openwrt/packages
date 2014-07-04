#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl
PKG_VERSION:=5.10.0
PKG_RELEASE:=7
PKG_MD5SUM:=d2c39b002ebfd2c3c5dba589365c5a71

PKG_SOURCE_URL:=ftp://ftp.cpan.org/pub/CPAN/src/5.0 \
		ftp://ftp.mpi-sb.mpg.de/pub/perl/CPAN/src/5.0 \
		ftp://ftp.gmd.de/mirrors/CPAN/src/5.0 \
		ftp://ftp.funet.fi/pub/languages/perl/CPAN/src/5.0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_LICENSE:=GPLv1 ARTISTIC
PKG_LICENSE_FILES:=Copying Artisitc README

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

ifneq ($(CONFIG_USE_EGLIBC),)
EXTRA_LIBS:=bsd
EXTRA_LIBDIRS:=$(STAGING_DIR)/lib
endif

define Package/perl/Default
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=The Perl intepreter
  URL:=http://www.perl.com/
  DEPENDS:=+USE_EGLIBC:libbsd
endef

define Package/microperl
$(call Package/perl/Default)
  TITLE+=(minimal version)
endef

define Package/microperl/description
 A perl package without operating-specific functions such as readdir.
endef

define Build/Template

$(STAMP_CONFIGURED)-$(1): $(STAMP_PREPARED)
	-$(MAKE) -C $(PKG_BUILD_DIR) clean
	$(call Build/$(1)/Configure)
	touch $$@

$(STAMP_BUILT)-$(1): $(STAMP_CONFIGURED)-$(1)
	$(call Build/$(1)/Compile)
	touch $$@

$(STAMP_BUILT): $(STAMP_BUILT)-$(1)

endef

define Build/microperl/Configure
endef

define Build/microperl/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) -f Makefile.micro \
		CC="$(TARGET_CC)" OPTIMIZE="$(TARGET_CFLAGS)"
	$(INSTALL_DIR) $(PKG_INSTALL_DIR)/usr/bin/
	$(CP) $(PKG_BUILD_DIR)/microperl $(PKG_INSTALL_DIR)/usr/bin/
endef

define Package/microperl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/microperl $(1)/usr/bin/
endef

include perlmod.mk

define Package/perl
$(call Package/perl/Default)
endef

define Package/perl/description
 Perl is a stable, cross platform programming language.
 It is used for mission critical projects in the public and private sectors
 and is widely used to program web applications of all needs.
endef

define Build/perl/Configure
	@echo
	@echo "===> Stage 1: Configure host perl"
	@echo
	mkdir -p $(PKG_BUILD_DIR)/host-perl
	(cd $(PKG_BUILD_DIR)/host-perl && sh ../Configure -der -Dmksymlinks -Uusedl -Dotherlibdirs=$(PERL_LIB))

	@echo
	@echo "===> Stage 2: Build host perl binary with static extensions"
	@echo
	$(MAKE) -C $(PKG_BUILD_DIR)/host-perl

	@echo
	@echo "===> Stage 3: Configure target perl"
	@echo
	-$(MAKE) -C $(PKG_BUILD_DIR) clean
	sed \
		-e 's!%%CC%%!$(TARGET_CC)!g' \
		-e 's!%%CFLAGS%%!$(TARGET_CFLAGS) -DUSE_CROSS_COMPILE $(TARGET_CPPFLAGS)!g' \
		-e 's!%%CPP%%!$(TARGET_CROSS)gcc -E!g' \
		-e 's!%%AR%%!$(TARGET_CROSS)ar!g' \
		-e 's!%%LD%%!$(TARGET_CROSS)gcc!g' \
		-e 's!%%LDFLAGS%%!-rdynamic $(TARGET_LDFLAGS)!g' \
		-e 's!%%LIBDIRS%%!$(STAGING_DIR)/lib $(STAGING_DIR)/usr/lib!g' \
		-e 's!%%INCDIRS%%!$(STAGING_DIR)/include $(STAGING_DIR)/usr/include!g' \
		-e 's!%%EXTRA_PERLLIBS%%!$(EXTRA_LIBS:%=-l%)!g' \
		-e 's!%%EXTRA_PERLLIBDIRS%%!$(EXTRA_LIBDIRS:%=-L%)!g' \
		files/config.sh-$(patsubst i386,i486,$(ARCH)).in \
		> $(PKG_BUILD_DIR)/config.sh
	(cd $(PKG_BUILD_DIR) && ./Configure -S)
endef

define Build/perl/Compile
	@echo
	@echo "===> Stage 4: Build target miniperl binary"
	@echo
	install -m 0644 $(PKG_BUILD_DIR)/config.h $(PKG_BUILD_DIR)/xconfig.h
	-rm -f $(PKG_BUILD_DIR)/miniperl
	$(MAKE) -C $(PKG_BUILD_DIR) miniperl
	mkdir -p $(PKG_BUILD_DIR)/target-bin
	install -m 0755 $(PKG_BUILD_DIR)/miniperl $(PKG_BUILD_DIR)/target-bin/

	@echo
	@echo "===> Stage 5: Build target perl binary"
	@echo
	-rm -f $(PKG_BUILD_DIR)/miniperl $(PKG_BUILD_DIR)/perl
	install -m 0755 $(PKG_BUILD_DIR)/host-perl/miniperl $(PKG_BUILD_DIR)/
	touch $(PKG_BUILD_DIR)/miniperl
	$(MAKE) -C $(PKG_BUILD_DIR) perl
	install -m 0755 $(PKG_BUILD_DIR)/perl $(PKG_BUILD_DIR)/target-bin/

	@echo
	@echo "===> Stage 6: Build target extensions and utils"
	@echo
	-rm -f $(PKG_BUILD_DIR)/miniperl $(PKG_BUILD_DIR)/perl
	install -m 0755 $(PKG_BUILD_DIR)/host-perl/miniperl $(PKG_BUILD_DIR)/
	ln -sf miniperl $(PKG_BUILD_DIR)/perl
	touch $(PKG_BUILD_DIR)/miniperl $(PKG_BUILD_DIR)/perl
	$(MAKE) -C $(PKG_BUILD_DIR)

	@echo
	@echo "===> Stage 7: Install Perl into staging dir"
	@echo
	-rm -f $(PKG_BUILD_DIR)/perl
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/host-perl/perl $(PKG_BUILD_DIR)/
	(cd $(PKG_BUILD_DIR) && ./perl installperl --destdir=$(STAGING_DIR))

	@echo
	@echo "===> Stage 8: Install Perl into a temporary root"
	@echo
	-rm -f $(PKG_BUILD_DIR)/perl
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target-bin/perl $(PKG_BUILD_DIR)
	-rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	(cd $(PKG_BUILD_DIR) && host-perl/miniperl installperl --destdir=$(PKG_INSTALL_DIR))
endef

define Package/perl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/perl$(PKG_VERSION) $(1)/usr/bin
	ln -nsf perl$(PKG_VERSION) $(1)/usr/bin/perl
endef

ifneq ($(CONFIG_PACKAGE_microperl),)
define Build/microperl
	$(call Build/Template,microperl)
endef
endif
$(eval $(Build/microperl))

ifneq ($(CONFIG_PACKAGE_perl),)
define Build/perl
	$(call Build/Template,perl)
endef
endif
$(eval $(Build/perl))

define Build/Configure
endef

define Build/Compile
endef

$(eval $(call RequireCommand,rsync, \
	$(PKG_NAME) requires rsync installed on the host-system. \
))

$(eval $(call BuildPackage,microperl))
$(eval $(call BuildPackage,perl))

-include perlbase.mk
