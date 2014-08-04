# This makefile simplifies perl module builds.
#

# Build environment
HOST_PERL_PREFIX:=$(STAGING_DIR_HOST)/usr
ifneq ($(CONFIG_USE_EGLIBC),)
	EXTRA_LIBS:=bsd
	EXTRA_LIBDIRS:=$(STAGING_DIR)/lib
endif
PERL_CMD:=$(STAGING_DIR_HOST)/usr/bin/perl5.20.0

# Module install prefix
PERL_SITELIB:=/usr/lib/perl5/5.20

define perlmod/Configure
	(cd $(PKG_BUILD_DIR); \
	PERL_MM_USE_DEFAULT=1 \
	$(2) \
	$(PERL_CMD) Makefile.PL \
		$(1) \
		AR=ar \
		CC=$(GNU_TARGET_NAME)-gcc \
		CCFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
		CCCDLFLAGS=-fPIC \
		CCDLFLAGS=-Wl,-E \
		DLEXT=so \
		DLSRC=dl_dlopen.xs \
		EXE_EXT=" " \
		FULL_AR=$(GNU_TARGET_NAME)-ar \
		LD=$(GNU_TARGET_NAME)-gcc \
		LDDLFLAGS="-shared $(TARGET_LDFLAGS)"  \
		LDFLAGS="$(EXTRA_LIBDIRS:%=-L%) $(EXTRA_LIBS:%=-l%) " \
		LIBC=" " \
		LIB_EXT=.a \
		OBJ_EXT=.o \
		OSNAME=linux \
		OSVERS=2.4.30 \
		RANLIB=: \
		SITELIBEXP=" " \
		SITEARCHEXP=" " \
		SO=so  \
		VENDORARCHEXP=" " \
		VENDORLIBEXP=" " \
		SITEPREFIX=/usr \
		INSTALLPRIVLIB=$(PERL_SITELIB) \
		INSTALLSITELIB=$(PERL_SITELIB) \
		INSTALLVENDORLIB=" " \
		INSTALLARCHLIB=$(PERL_SITELIB) \
		INSTALLSITEARCH=$(PERL_SITELIB) \
		INSTALLVENDORARCH=" " \
		INSTALLBIN=/usr/bin \
		INSTALLSITEBIN=/usr/bin \
		INSTALLVENDORBIN=" " \
		INSTALLSCRIPT=/usr/bin \
		INSTALLSITESCRIPT=/usr/bin \
		INSTALLVENDORSCRIPT=" " \
		INSTALLMAN1DIR=/usr/man/man1 \
		INSTALLSITEMAN1DIR=/usr/man/man1 \
		INSTALLVENDORMAN1DIR=" " \
		INSTALLMAN3DIR=/usr/man/man3 \
		INSTALLSITEMAN3DIR=/usr/man/man3 \
		INSTALLVENDORMAN3DIR=" " \
		LINKTYPE=dynamic \
		DESTDIR=$(PKG_INSTALL_DIR) \
	);
	sed 's!^PERL_INC = .*!PERL_INC = $(STAGING_DIR)/usr/lib/perl5/5.20/CORE/!' -i $(PKG_BUILD_DIR)/Makefile
endef

define perlmod/Compile
	PERL5LIB=$(PERL_LIB) \
	$(2) \
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(1) \
		install
endef

define perlmod/Install
	$(INSTALL_DIR) $(strip $(1))$(PERL_SITELIB)
	(cd $(PKG_INSTALL_DIR)$(PERL_SITELIB) && \
	rsync --relative -rlHp --itemize-changes \
		--exclude=\*.pod \
		--exclude=.packlist \
		$(addprefix --exclude=/,$(strip $(3))) \
		--prune-empty-dirs \
		$(strip $(2)) $(strip $(1))$(PERL_SITELIB))

	chmod -R u+w $(strip $(1))$(PERL_SITELIB)

	@echo "---> Stripping modules in: $(strip $(1))$(PERL_SITELIB)"
	find $(strip $(1))$(PERL_SITELIB) -name \*.pm -or -name \*.pl | \
	xargs -r sed -i \
		-e '/^=\(head\|pod\|item\|over\|back\|encoding\)/,/^=cut/d' \
		-e '/^=\(head\|pod\|item\|over\|back\|encoding\)/,$$$$d' \
		-e '/^#$$$$/d' \
		-e '/^#[^!"'"'"']/d'
endef
