# This makefile simplifies perl module builds.
#

# Build environment
PERL_CMD := $(STAGING_DIR)/usr/bin/perl
PERL_LIB := $(STAGING_DIR)/usr/lib/perl5/5.10

# Module install prefix
PERL_SITELIB := /usr/lib/perl5/5.10

define perlmod/Configure
	(cd $(PKG_BUILD_DIR); \
	PERL5LIB=$(PERL_LIB) \
	PERL_MM_USE_DEFAULT=1 \
	$(2) \
	$(PERL_CMD) Makefile.PL \
		$(1) \
		PERL_LIB=$(PERL_LIB) \
		PERL_ARCHLIB=$(PERL_LIB) \
		INSTALLSITELIB=$(PERL_SITELIB) \
		INSTALLSITEARCH=$(PERL_SITELIB) \
		DESTDIR=$(PKG_INSTALL_DIR) \
	);
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
		-e '/^=\(head\|pod\|item\|over\|back\)/,/^=cut/d' \
		-e '/^=\(head\|pod\|item\|over\|back\)/,$$$$d' \
		-e '/^#$$$$/d' \
		-e '/^#[^!"'"'"']/d'
endef
