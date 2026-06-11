include $(TOPDIR)/rules.mk

PKG_NAME:=mandoc
PKG_VERSION:=1.14.6
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://mandoc.bsd.lv/snapshots/
PKG_HASH:=8bf0d570f01e70a6e124884088870cbed7537f36328d512909eb10cd53179d9c

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=BSD-3-Clause BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/mandoc
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=mandoc document formatting system
  DEPENDS:=+zlib
  URL:=https://mandoc.bsd.lv/
endef

define Package/sed/description
mandoc is a suite of tools compiling mdoc, the roff macro language
of choice for BSD manual pages, and man, the predominant historical
language for UNIX manuals. It is small, ISO C, ISC-licensed, and quite
fast. The main component of the toolset is the mandoc utility program,
based on the libmandoc validating compiler, to format output for UTF-8
and ASCII UNIX terminals, HTML 5, PostScript, and PDF.
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	{ \
	    echo PREFIX=/usr; \
	    echo HAVE_FTS=0; \
	    echo HAVE_REALLOCARRAY=0; \
	    echo "#Fix build on Darwin host (that values must be used for target build):"; \
	    echo HAVE_DIRENT_NAMLEN=0; \
	    echo HAVE_ENDIAN=1; \
	    echo HAVE_SYS_ENDIAN=0; \
	    echo HAVE_EFTYPE=0; \
	    echo HAVE_PROGNAME=0; \
	    echo HAVE_REWB_BSD=0; \
	    echo HAVE_REWB_SYSV=1; \
	    echo HAVE_STRCASESTR=1; \
	    echo HAVE_STRINGLIST=0; \
	    echo HAVE_STRLCAT=0; \
	    echo HAVE_STRLCPY=0; \
	    echo HAVE_STRPTIME=1; \
	    echo HAVE_STRTONUM=0; \
	    echo HAVE_VASPRINTF=1; \
	    echo NEED_GNU_SOURCE=1; \
	    echo HAVE_WCHAR=1; \
	    echo UTF8_LOCALE=en_US.utf8; \
	    echo STATIC=-static; \
	} > $(PKG_BUILD_DIR)/configure.local
endef

define Package/mandoc/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mandoc $(1)/usr/bin/
endef

$(eval $(call BuildPackage,mandoc))
