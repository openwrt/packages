include $(TOPDIR)/rules.mk

PKG_NAME:=perl-html-parser
PKG_VERSION:=3.83
PKG_RELEASE:=1

METACPAN_NAME:=HTML-Parser
METACPAN_AUTHOR:=OALDERS
PKG_HASH:=7278ce9791256132b26a71a5719451844704bb9674b58302c3486df43584f8c0

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

HOST_BUILD_DEPENDS:=perl/host

include ../metacpan.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../perlmod.mk

define Package/perl-html-parser
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=HTML parser class
  URL:=https://metacpan.org/pod/HTML::Parser
  DEPENDS:=perl +perlbase-essential +perlbase-xsloader +perl-html-tagset +perl-http-message
endef

define Package/perl-html-parser/description
  Objects of the HTML::Parser class will recognize markup
  and separate it from plain text (alias data content) in
  HTML documents.
endef

define Build/Configure
    $(call perlmod/Configure,,)
endef

define Build/Compile
    $(call perlmod/Compile,,)
endef

define Package/perl-html-parser/install
    $(call perlmod/Install,$(1),HTML auto/HTML)
endef

define Host/Configure
    $(call perlmod/host/Configure,,,)
endef

define Host/Compile
    $(call perlmod/host/Compile,,)
endef

define Host/Install
    $(call perlmod/host/Install,$(1),)
endef

$(eval $(call BuildPackage,perl-html-parser))
$(eval $(call HostBuild))
