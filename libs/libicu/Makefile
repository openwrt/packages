#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=icu
PKG_VERSION:=54.1
PKG_RELEASE:=1

PKG_SOURCE:=icu4c-54_1-src.tgz
PKG_SOURCE_URL:=http://download.icu-project.org/files/icu4c/$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/icu
PKG_INSTALL=1
PKG_MD5SUM:=e844caed8f2ca24c088505b0d6271bc0
PKG_LICENSE:= ICU License <http://www.icu-project.org/repos/icu/icu/tags/release-54-1/license.html>
PKG_MAINTAINER:=Carlos M. Ferreira <carlosmf.pt@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/libicu
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:= ICU library - International Components for Unicode
  URL:=http://site.icu-project.org/
  DEPENDS:=+libstdcpp
endef

define Package/libicu/description
	ICU is the premier library for software internationalization. 
	ICU 54 is a major release of ICU, with new features, new APIs and many bug fixes in 
	data and code. 
	It supports the latest versions of the Unicode locale data (CLDR 26, September 2014) 
	and Unicode Standard (Unicode 7.0, June 2014). The improvements include 72 new 
	measurement units, Unihan radical-stroke collation moved into root, new RBNF 
	PluralFormat syntax, dictionary-based word and line break for Burmese, support for 
	short locale display names, compatibility support for IANA time zone data 
	abbreviations, a tech preview of FilteredBreakIterator using ULI break data, ICU4C 
	thread safety fixes, and the ability to build ICU4C Paragraph Layout with HarfBuzz.
	For more info, see <http://site.icu-project.org/download/54>
endef


define Package/libicu/config 
	menu "Select ICU library configuration options."
		depends on PACKAGE_libicu
		comment "More info here <http://www.icu-project.org/repos/icu/icu/tags/release-54-1/readme.html>."
		config LIBICU_U_USING_ICU_NAMESPACE				
	    	bool "Use ICU namespace."
	    	default n
	    	help 
	    		By default, unicode/uversion.h has "using namespace icu;" which defeats 
	    		much of the purpose of the namespace. (This is for historical 
	    		reasons: Originally, ICU4C did not use namespaces, and some compilers 
	    		did not support them. The default "using" statement preserves source 
	    		code compatibility.) If this compatibility is not an issue, we 
	    		recommend you turn this off.
				
	    config LIBICU_U_CHARSET_IS_UTF8	    	
	    	bool "Hardcode the default charset to UTF-8"
	    	default y
	    	help
	    		On platforms where the default charset is always UTF-8, like MacOS X and 
	    		some Linux distributions, we recommend hardcoding ICU's default charset 
	    		to UTF-8. This means that some implementation code becomes simpler and 
	    		faster, and statically linked ICU libraries become smaller. 
			    	
	    config LIBICU_UNICODE_CONSTRUCTORS	    	
	    	bool "UnicodeString constructors"
	    	default y
	    	help
	    		The UnicodeString class has several single-argument constructors that are 
	    		not marked "explicit" for historical reasons. This can lead to inadvertent 
	    		construction of a UnicodeString with a single character by using an 
	    		integer, and it can lead to inadvertent dependency on the conversion 
	    		framework by using a C string literal.

	    config LIBICU_U_NO_DEFAULT_INCLUDE_UTF_HEADERS	    	
	    	bool "utf.h, utf8.h, utf16.h, utf_old.h explicit include is requirement."
	    	default y
	    	help
	    		By default, utypes.h (and thus almost every public ICU header) includes 
	    		all of these header files. Often, none of them are needed, or only one 
	    		or two of them. All of utf_old.h is deprecated or obsolete.
				When this option is selected, it is required to explicitly include the 
				utf headers that are actually used.

		choice
			prompt "Selected compilation mode."			
			config LIBICU_DYNAMIC_LIB
				bool "Compile ICU library dinamically"

			config LIBICU_STATIC_LIB
				bool "Compile ICU library statically"			
		endchoice
    endmenu
endef


MAKE_PATH:=source
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/icu

TARGET_CPPFLAGS+= $(if $(CONFIG_LIBICU_U_USING_ICU_NAMESPACE),-DU_USING_ICU_NAMESPACE=1,-DU_USING_ICU_NAMESPACE=0) \
	$(if $(CONFIG_LIBICU_U_CHARSET_IS_UTF8),-DU_CHARSET_IS_UTF8=1,) \
	$(if $(CONFIG_LIBICU_UNICODE_CONSTRUCTORS),-DUNISTR_FROM_CHAR_EXPLICIT=explicit -DUNISTR_FROM_STRING_EXPLICIT=explicit,) \
	$(if $(CONFIG_LIBICU_U_NO_DEFAULT_INCLUDE_UTF_HEADERS),-DU_NO_DEFAULT_INCLUDE_UTF_HEADERS=1,)


define Host/Compile	
	($(MAKE) -C $(HOST_BUILD_DIR)/source CPPFLAGS="$(call TARGET_CPPFLAGS)" VERBOSE=1 all install)
endef

define Build/Prepare
	mkdir -p $(HOST_BUILD_DIR)
	$(call Host/Prepare/Default)
	$(call Host/Configure/Default,,,source)
	$(call Host/Compile)
	$(call Build/Prepare/Default)
endef

define Build/Configure	
	$(call Build/Configure/Default, --with-cross-build=$(HOST_BUILD_DIR)/source $(if $(CONFIG_LIBICU_DYNAMIC_LIB),,--enable-static --disable-shared),, source)
endef

define Package/libicu/install
	$(INSTALL_DIR) $(1)/usr/lib
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,libicu))
