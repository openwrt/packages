#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# To Do:
#  - dirs not removed when uninstalling!
#
include $(TOPDIR)/rules.mk

PKG_NAME:=ruby
PKG_VERSION:=2.2.4
PKG_RELEASE:=1

PKG_LIBVER:=2.2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://cache.ruby-lang.org/pub/ruby/$(PKG_LIBVER)/
PKG_MD5SUM:=c3d65f6d2ebe90dda81a37885ea244f5
PKG_MAINTAINER:=Luiz Angelo Daros de Luca <luizluca@gmail.com>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DEPENDS:=ruby/host
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/ruby/Default
  SUBMENU:=Ruby
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Ruby scripting language
  URL:=http://www.ruby-lang.org/
endef

define Package/ruby/Default/description
 Ruby is the interpreted scripting language for quick and easy
 object-oriented programming.  It has many features to process text files
 and to do system management tasks (as in perl).  It is simple,
 straight-forward, and extensible.

endef

define Package/ruby
$(call Package/ruby/Default)
  TITLE+= (interpreter)
  DEPENDS:=+libruby
endef

define Package/ruby/description
$(call Package/ruby/Default/description)
endef

define Package/libruby
$(call Package/ruby/Default)
  SUBMENU:=
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+= (shared library)
  DEPENDS+= +libpthread +librt +libgmp
endef

define Package/ruby-stdlib
$(call Package/ruby/Default)
  TITLE:=Ruby standard libraries (metadata for all stdlib subsets)
  DEPENDS:=ruby +ruby-misc +ruby-bigdecimal +ruby-cgi +ruby-csv +ruby-datetime +ruby-dbm +ruby-debuglib\
			+ruby-digest +ruby-drb +ruby-enc +ruby-enc-extra +ruby-erb +ruby-gdbm +ruby-gems \
			+ruby-json +ruby-io-console +ruby-irb +ruby-fiddle +ruby-filelib +ruby-logger +ruby-math \
			+ruby-minitest +ruby-mkmf +ruby-multithread +ruby-nkf +ruby-net +ruby-openssl +ruby-optparse \
			+ruby-patterns +ruby-powerassert +ruby-prettyprint +ruby-pstore +ruby-psych +ruby-racc +ruby-rake \
			+ruby-rbconfig +ruby-rdoc +ruby-readline +ruby-rexml +ruby-rinda +ruby-ripper +ruby-rss +ruby-sdbm \
			+ruby-shell +ruby-socket +ruby-testunit +ruby-unicodenormalize +ruby-uri +ruby-webrick +ruby-xmlrpc \
			+ruby-yaml +ruby-zlib
endef

define Package/ruby-stdlib/description
 This metapackage currently install all ruby-* packages,
 providing a complete Ruby Standard Library.

endef

define Package/ruby-bigdecimal
$(call Package/ruby/Default)
  TITLE:=Arbitrary-precision decimal floating-point lib for Ruby
  DEPENDS:=ruby
endef

define Package/ruby-bigdecimal/description
 Provides bigdecimal* files
endef

define Package/ruby-cgi
$(call Package/ruby/Default)
  TITLE:=Ruby CGI support toolkit
  DEPENDS:=ruby +ruby-filelib +ruby-pstore
endef

define Package/ruby-bigdecimal/description
 Provides bigdecimal* files

endef

define Package/ruby-csv
$(call Package/ruby/Default)
  TITLE+=CSV library
  DEPENDS:=ruby +ruby-patterns +ruby-datetime +ruby-enc
endef

define Package/ruby-csv/description
 Provides csv.rb file

endef

define Package/ruby-datetime
$(call Package/ruby/Default)
  TITLE+= date library
  DEPENDS:=ruby
endef

define Package/ruby-datetime/description
 Provides date.rb and time.rb

endef

define Package/ruby-dbm
$(call Package/ruby/Default)
  TITLE:=Ruby support for dbm
  DEPENDS:=ruby +libdb47
endef

define Package/ruby-dbm/description
 The DBM class provides a wrapper to a Unix-style dbm or Database Manager library.
 This package provides dbm.so file.

endef

define Package/ruby-debuglib
$(call Package/ruby/Default)
  TITLE+= debug library
  DEPENDS:=ruby +ruby-multithread +ruby-prettyprint
endef

define Package/ruby-debuglib/description
 Provides files for debugging:
 - benchmark.rb
 - debug.rb
 - objspace.so
 - profile.rb
 - profiler.rb
 - tracer.rb

endef

define Package/ruby-digest
$(call Package/ruby/Default)
  TITLE:=Ruby Digest Library
  DEPENDS:=ruby +RUBY_DIGEST_USE_OPENSSL:libopenssl
endef

define Package/ruby-digest/description
 Provides digest* files. Can be configured to use OpenSSL or
 bundled hash functions.

endef

define Package/ruby-digest/config

	config RUBY_DIGEST_USE_OPENSSL
		bool "Use OpenSSL functions for ruby digest hash functions"
        depends on PACKAGE_ruby-digest
		help
			Ruby can use OpenSSL hash functions or compile alternative implementations. Using
			OpenSSL saves about 30KBytes (less when compressed) but requires OpenSSL (that
			is way bigger than that). However, if OpenSSL is already needed by another usage,
			as ruby-openssl or any other non ruby package, it is better to mark this option.
		default n

endef

define Package/ruby-drb
$(call Package/ruby/Default)
  TITLE:=Ruby distributed object system
  DEPENDS:=ruby +ruby-filelib +ruby-patterns +ruby-socket
endef

define Package/ruby-drb/description
 Provides drb* files

endef

define Package/ruby-enc
$(call Package/ruby/Default)
  TITLE:=Ruby character re-coding library charset (small subset)
  DEPENDS:=ruby
endef

define Package/ruby-enc/description
 Provides ruby encoding library for encodings used directly by
 libraries in Ruby Standard Library:
 - enc/encdb.so
 - enc/euc_jp.so
 - enc/iso_8859_1.so
 - enc/utf_16be.so
 - enc/utf_16le.so
 - enc/utf_32be.so
 - enc/utf_32le.so
 FYI: ASCII-8BIT, UTF-7, UTF-8 and US-ASCII are already in Core.

endef

define Package/ruby-enc-extra
$(call Package/ruby/Default)
  TITLE:=Ruby character re-coding library charset (extra subset)
  DEPENDS:=ruby +ruby-enc
endef

define Package/ruby-enc-extra/description
 Provides extra encodings not provided by ruby-enc:
 - enc/big5.so
 - enc/cp949.so
 - enc/emacs_mule.so
 - enc/euc_kr.so
 - enc/euc_tw.so
 - enc/gb18030.so
 - enc/gb2312.so
 - enc/gbk.so
 - enc/iso_8859_10.so
 - enc/iso_8859_11.so
 - enc/iso_8859_13.so
 - enc/iso_8859_14.so
 - enc/iso_8859_15.so
 - enc/iso_8859_16.so
 - enc/iso_8859_2.so
 - enc/iso_8859_3.so
 - enc/iso_8859_4.so
 - enc/iso_8859_5.so
 - enc/iso_8859_6.so
 - enc/iso_8859_7.so
 - enc/iso_8859_8.so
 - enc/iso_8859_9.so
 - enc/koi8_r.so
 - enc/koi8_u.so
 - enc/shift_jis.so
 - enc/trans/big5.so
 - enc/trans/chinese.so
 - enc/trans/emoji.so
 - enc/trans/emoji_iso2022_kddi.so
 - enc/trans/emoji_sjis_docomo.so
 - enc/trans/emoji_sjis_kddi.so
 - enc/trans/emoji_sjis_softbank.so
 - enc/trans/escape.so
 - enc/trans/gb18030.so
 - enc/trans/gbk.so
 - enc/trans/iso2022.so
 - enc/trans/japanese.so
 - enc/trans/japanese_euc.so
 - enc/trans/japanese_sjis.so
 - enc/trans/korean.so
 - enc/trans/single_byte.so
 - enc/trans/transdb.so
 - enc/trans/utf8_mac.so
 - enc/trans/utf_16_32.so
 - enc/windows_1251.so
 - enc/windows_31j.so

endef

define Package/ruby-erb
$(call Package/ruby/Default)
  TITLE+= (embedded interpreter)
  DEPENDS:=ruby +ruby-cgi
endef

define Package/ruby-erb/description
 Provides erb* files

endef

define Package/ruby-fiddle
$(call Package/ruby/Default)
  TITLE:=A libffi wrapper for Ruby
  DEPENDS:=ruby +libffi
endef

define Package/ruby-fiddle/description
 Provides fiddle* files

endef

define Package/ruby-filelib
$(call Package/ruby/Default)
  TITLE+= File utils library
  DEPENDS:=ruby +ruby-enc +ruby-misc
endef

define Package/ruby-filelib/description
 Provides filesystem interaction files, including
 path and temp:
 - fileutils.rb
 - find.rb
 - pathname.rb
 - pathname.so
 - tempfile.rb
 - tmpdir.rb

endef

define Package/ruby-gdbm
$(call Package/ruby/Default)
  TITLE:=Ruby support for gdbm
  DEPENDS:=ruby +libgdbm
endef

define Package/ruby-gdbm/description
 Provides gdbm* files

endef

define Package/ruby-gems
$(call Package/ruby/Default)
  TITLE:=Ruby gems packet management
  DEPENDS:=ruby +ruby-net +ruby-rdoc
endef

define Package/ruby-gems/description
 Provides rubygems for gems usage, download and installation

endef

define Package/ruby-io-console
$(call Package/ruby/Default)
  TITLE+= Console interface
  DEPENDS:=ruby
endef

define Package/ruby-io-console/description
 Provides io-console* files

endef

define Package/ruby-irb
$(call Package/ruby/Default)
  TITLE+= (interactive shell)
  DEPENDS:=ruby +ruby-debuglib +ruby-filelib +ruby-math
endef

define Package/ruby-irb/description
 Provides irb* files

endef

define Package/ruby-json
$(call Package/ruby/Default)
  TITLE:=Ruby support for JSON
  DEPENDS:=ruby +ruby-datetime +ruby-misc
endef

define Package/ruby-json/description
 Provides json* files

endef

define Package/ruby-logger
$(call Package/ruby/Default)
  TITLE+= logger and syslog library
  DEPENDS:=ruby +ruby-multithread
endef

define Package/ruby-logger/description
 Provides log library, including syslog:
 - logger.rb
 - syslog.so
 - syslog/logger.rb

endef

define Package/ruby-math
$(call Package/ruby/Default)
  TITLE+= math library
  DEPENDS:=ruby +ruby-patterns
endef

define Package/ruby-math/description
 Provides math related files:
 - cmath.rb
 - complex.rb
 - mathn.rb
 - mathn/complex.so
 - mathn/rational.so
 - matrix.rb
 - matrix/eigenvalue_decomposition.rb
 - matrix/lup_decomposition.rb
 - prime.rb
 - rational.rb

endef

define Package/ruby-minitest
$(call Package/ruby/Default)
  TITLE:=Gem minitest shipped with Ruby
  DEPENDS:=ruby +ruby-gems
endef

define Package/ruby-minitest/description
 Provides minitest gem

endef

define Package/ruby-misc
$(call Package/ruby/Default)
  TITLE:=Ruby standard libraries subset (miscelaneous files)
  DEPENDS:=ruby
endef

define Package/ruby-misc/description
 This package contains miscellaneous files from stdlib
 not splitted in other ruby packages like stringio:
 - English.rb
 - abbrev.rb
 - base64.rb
 - continuation.so
 - coverage.so
 - delegate.rb
 - e2mmap.rb
 - etc.so
 - expect.rb
 - fcntl.so
 - fiber.so
 - getoptlong.rb
 - open3.rb
 - ostruct.rb
 - pty.so
 - scanf.rb
 - securerandom.rb
 - set.rb
 - shellwords.rb
 - stringio.so
 - strscan.so
 - tsort.rb
 - weakref.rb

endef

define Package/ruby-mkmf
$(call Package/ruby/Default)
  TITLE+= makefile library
  DEPENDS:=ruby +ruby-filelib +ruby-optparse +ruby-rbconfig
endef

define Package/ruby-mkmf/description
 Provides mkmf* files

endef

define Package/ruby-multithread
$(call Package/ruby/Default)
  TITLE+= multithread library
  DEPENDS:=ruby +ruby-misc
endef

define Package/ruby-multithread/description
 Provides files for multithread usage:
 - io/nonblock.so
 - io/wait.so
 - thread.so (FYI, Thread is a core class)
 - monitor.rb
 - mutex_m.rb
 - sync.rb
 - thwait.rb
 - timeout.rb

endef

define Package/ruby-net
$(call Package/ruby/Default)
  TITLE:=Ruby Network Protocols Library
  DEPENDS:=ruby +ruby-datetime +ruby-digest +ruby-filelib +ruby-uri
endef

define Package/ruby-net/description
 Provides net* files

endef

define Package/ruby-nkf
$(call Package/ruby/Default)
  TITLE:=Ruby Network Kanji Filter
  DEPENDS:=ruby +ruby-enc
endef

define Package/ruby-nkf/description
 Provides nkf* files

endef

define Package/ruby-openssl
$(call Package/ruby/Default)
  TITLE:=Ruby support for openssl
  DEPENDS:=ruby +ruby-enc +libopenssl +ruby-misc
endef

define Package/ruby-openssl/description
 Provides openssl* files

endef

define Package/ruby-optparse
$(call Package/ruby/Default)
  TITLE:=Ruby command-line option analysis
  DEPENDS:=ruby +ruby-misc
endef

define Package/ruby-optparse/description
 Provides optparse* files

endef

define Package/ruby-patterns
$(call Package/ruby/Default)
  TITLE:=Ruby design patterns implementation
  DEPENDS:=ruby +ruby-multithread
endef

define Package/ruby-patterns/description
 Provides design patterns helpers files:
 - forwardable.rb
 - observer.rb
 - singleton.rb

endef

define Package/ruby-powerassert
$(call Package/ruby/Default)
  TITLE:=Gem power_assert shipped with Ruby
  DEPENDS:=ruby +ruby-ripper
endef

define Package/ruby-powerassert/description
  Power Assert gem for Ruby. Power Assert shows each value of variables
  and method calls in the expression. It is useful for testing, providing
  which value wasn't correct when the condition is not satisfied

endef

define Package/ruby-prettyprint
$(call Package/ruby/Default)
  TITLE:=Ruby PrettyPrint librart
  DEPENDS:=ruby +ruby-misc
endef

define Package/ruby-prettyprint/description
 Provides Pretty Print library:
 - pp.rb
 - prettyprint.rb

endef

define Package/ruby-pstore
$(call Package/ruby/Default)
  TITLE+=file based persistence
  DEPENDS:=ruby +ruby-digest +ruby-enc
endef

define Package/ruby-pstore/description
 Provides pstore.rb file

endef

define Package/ruby-psych
$(call Package/ruby/Default)
  TITLE+=YAML parser and emitter
  DEPENDS:=ruby +ruby-bigdecimal +ruby-datetime +ruby-misc +ruby-enc +libyaml
endef

define Package/ruby-psych/description
 Provides psych* files

endef

define Package/ruby-racc
$(call Package/ruby/Default)
  TITLE:=LALR parser generator in Ruby
  DEPENDS:=ruby
endef

define Package/ruby-racc/description
 Provides racc* files

endef

define Package/ruby-rake
$(call Package/ruby/Default)
  TITLE+=Ruby Rake (make replacement)
  DEPENDS:=ruby +ruby-datetime +ruby-filelib +ruby-optparse +ruby-patterns +ruby-rbconfig
endef

define Package/ruby-rake/description
 Provides rake* files

endef

define Package/ruby-rbconfig
$(call Package/ruby/Default)
  TITLE+=Ruby RbConfig
  DEPENDS:=ruby
endef

define Package/ruby-rbconfig/description
 Provides rbconfig file

endef

define Package/ruby-rdoc
$(call Package/ruby/Default)
  TITLE+= (documentation generator)
  DEPENDS:=ruby +ruby-erb +ruby-irb +ruby-json +ruby-racc +ruby-rake +ruby-yaml +ruby-zlib
endef

define Package/ruby-rdoc/description
 Provides rdoc* and ri files

endef

define Package/ruby-readline
$(call Package/ruby/Default)
  TITLE:=Ruby support for readline
  DEPENDS:=ruby +libncurses +libreadline
endef

define Package/ruby-readline/description
 Provides readline* files

endef

define Package/ruby-rexml
$(call Package/ruby/Default)
  TITLE:=Ruby XML toolkit
  DEPENDS:=ruby +ruby-patterns +ruby-enc
endef

define Package/ruby-rexml/description
 Provides rexml* files

endef

define Package/ruby-rinda
$(call Package/ruby/Default)
  TITLE:=Ruby Linda paradigm implementation
  DEPENDS:=ruby +ruby-drb
endef

define Package/ruby-rinda/description
 Provides rinda* files

endef

define Package/ruby-ripper
$(call Package/ruby/Default)
  TITLE:=Ruby script parser
  DEPENDS:=ruby
endef

define Package/ruby-ripper/description
 Provides ripper* files

endef

define Package/ruby-rss
$(call Package/ruby/Default)
  TITLE:=Ruby RSS toolkit
  DEPENDS:=ruby +ruby-net +ruby-nkf +ruby-rexml
endef

define Package/ruby-rss/description
 Provides rss* files

endef

define Package/ruby-sdbm
$(call Package/ruby/Default)
  TITLE:=Ruby simple file-based key-value dbm implementation
  DEPENDS:=ruby
endef

define Package/ruby-sdbm/description
 Provides sdbm* files

endef

define Package/ruby-shell
$(call Package/ruby/Default)
  TITLE:=Ruby idiomatic Ruby interface
  DEPENDS:=ruby +ruby-patterns
endef

define Package/ruby-shell/description
 Provides shell* files

endef

define Package/ruby-socket
$(call Package/ruby/Default)
  TITLE+= socket support
  DEPENDS:=ruby +ruby-multithread
endef

define Package/ruby-socket/description
 Provides socket-related files:
 - gserver.rb
 - ipaddr.rb
 - resolv-replace.rb
 - resolv.rb
 - socket.rb
 - socket.so

endef

define Package/ruby-testunit
$(call Package/ruby/Default)
  TITLE:=Gem test-unit shipped with Ruby
  DEPENDS:=ruby +ruby-csv +ruby-erb +ruby-optparse +ruby-powerassert +ruby-prettyprint +ruby-rexml +ruby-yaml
endef

define Package/ruby-testunit/description
 Provides test/unit* files

endef

define Package/ruby-unicodenormalize
$(call Package/ruby/Default)
  TITLE:=Ruby String additions for Unicode normalization
  DEPENDS:=ruby +ruby-enc +ruby-enc-extra
endef

define Package/ruby-unicodenormalize/description
  Additions to class String for Unicode normalization

endef

define Package/ruby-uri
$(call Package/ruby/Default)
  TITLE:=Ruby library to handle URI
  DEPENDS:=ruby +ruby-socket +ruby-enc
endef

define Package/ruby-uri/description
 Provides uri* files

endef

define Package/ruby-webrick
$(call Package/ruby/Default)
  TITLE:=Ruby Web server toolkit
  DEPENDS:=ruby +ruby-erb +ruby-net +ruby-patterns +ruby-rbconfig
endef

define Package/ruby-webrick/description
 Provides webrick* files

endef

define Package/ruby-xmlrpc
$(call Package/ruby/Default)
  TITLE:=Ruby XML-RPC toolkit
  DEPENDS:=ruby +ruby-rexml +ruby-webrick
endef

define Package/ruby-xmlrpc/description
 Provides xmlrpc* files

endef

define Package/ruby-yaml
$(call Package/ruby/Default)
  TITLE:=Ruby YAML toolkit
  DEPENDS:=ruby +ruby-dbm +ruby-pstore +ruby-psych
endef

define Package/ruby-yaml/description
 Provides yaml* files

endef

define Package/ruby-zlib
$(call Package/ruby/Default)
  TITLE:=Ruby support for zlib
  DEPENDS:=ruby +zlib
endef

define Package/ruby-zlib/description
 Provides zlib* files

endef

HOST_CONFIGURE_ARGS += \
	--disable-install-doc \
	--disable-install-rdoc \
	--disable-install-capi \
	--with-static-linked-ext \
	--with-out-ext=tk,tk/tkutil,win32,win32ole,dbm,gdbm,readline \

# even not used, host build with restricted exts results in gems not being
# compiling for target (probably some cross compiling problem like checking
# host for selecting target features)
#	--with-out-ext \
#	--with-ext=thread,stringio \

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--disable-rpath \
	--enable-ipv6 \
	--disable-install-doc \
	--disable-install-capi \
	--with-ruby-version=minor \
	--with-iconv-dir=$(ICONV_PREFIX) \
	--with-out-ext=tk,tk/tkutil,win32,win32ole

ifndef CONFIG_RUBY_DIGEST_USE_OPENSSL
CONFIGURE_ARGS += \
	--with-bundled-sha1\
	--with-bundled-md5\
	--with-bundled-rmd160\
	--with-bundled-sha2 \

endif

TARGET_LDFLAGS += -L$(PKG_BUILD_DIR)

# Ruby uses DLDFLAGS and not LDFLAGS for libraries. LDFLAGS is only for execs.
# However, DLDFLAGS from configure is not passed to Makefile when target is linux.
# XLDFLAGS is used by both libraries and execs. This is somehow brute force but
# if will fix when some LD_FLAGS is needef for libraries. As side effect, it will
# duplicate ld args for binaries.
CONFIGURE_VARS += XLDFLAGS="$(TARGET_LDFLAGS)"

MAKE_FLAGS += \
	DESTDIR="$(PKG_INSTALL_DIR)" \
	SHELL="/bin/bash"

define Package/ruby/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)
	$(INSTALL_DIR) $(1)/usr/lib/ruby/vendor_ruby/$(PKG_LIBVER)
	$(INSTALL_DIR) $(1)/usr/lib/ruby/site_ruby/$(PKG_LIBVER)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ruby $(1)/usr/lib/ruby/ruby$(PKG_LIBVER)-bin
	$(INSTALL_BIN) ./files/ruby $(1)/usr/bin/ruby
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/vendor_ruby/$(PKG_LIBVER)/* $(1)/usr/lib/ruby/vendor_ruby/$(PKG_LIBVER)/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/site_ruby/$(PKG_LIBVER)/* $(1)/usr/lib/ruby/site_ruby/$(PKG_LIBVER)/
	sed -i -e "s%@RUBY_LIBPATH@%/usr/lib/ruby/$(PKG_LIBVER)%" $(1)/usr/bin/ruby
	sed -i -e "s%@RUBY_BINPATH@%/usr/lib/ruby/ruby$(PKG_LIBVER)-bin%" $(1)/usr/bin/ruby
endef

define Package/libruby/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libruby.so.* $(1)/usr/lib/
endef

define Package/ruby-stdlib/install
	# nothing to do
endef

define Package/ruby-bigdecimal/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/*/bigdecimal.so \
		usr/lib/ruby/$(PKG_LIBVER)/bigdecimal/ \
		usr/lib/ruby/gems/$(PKG_LIBVER)/specifications/default/bigdecimal-*.gemspec \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-cgi/install
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/cgi $(1)/usr/lib/ruby/$(PKG_LIBVER)/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/cgi.rb $(1)/usr/lib/ruby/$(PKG_LIBVER)/
endef

define Package/ruby-csv/install
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/csv.rb $(1)/usr/lib/ruby/$(PKG_LIBVER)/
endef

define Package/ruby-datetime/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/time.rb \
		usr/lib/ruby/$(PKG_LIBVER)/date.rb \
		usr/lib/ruby/$(PKG_LIBVER)/*/date_core.so \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-dbm/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/*/dbm.so \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-debuglib/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/profile.rb \
		usr/lib/ruby/$(PKG_LIBVER)/profiler.rb \
		usr/lib/ruby/$(PKG_LIBVER)/debug.rb \
		usr/lib/ruby/$(PKG_LIBVER)/tracer.rb \
		usr/lib/ruby/$(PKG_LIBVER)/benchmark.rb \
		usr/lib/ruby/$(PKG_LIBVER)/*/objspace.so \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-digest/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/digest \
		usr/lib/ruby/$(PKG_LIBVER)/digest.rb \
		usr/lib/ruby/$(PKG_LIBVER)/*/digest.so \
		usr/lib/ruby/$(PKG_LIBVER)/*/digest/* \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-drb/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/drb.rb \
		usr/lib/ruby/$(PKG_LIBVER)/drb \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-enc/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/*/enc/encdb.so \
		usr/lib/ruby/$(PKG_LIBVER)/*/enc/iso_8859_1.so \
		usr/lib/ruby/$(PKG_LIBVER)/*/enc/utf_* \
		usr/lib/ruby/$(PKG_LIBVER)/*/enc/euc_jp.so \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-enc-extra/install
	( cd $(PKG_INSTALL_DIR); $(TAR) \
		--exclude=usr/lib/ruby/$(PKG_LIBVER)/*/enc/encdb.so \
		--exclude=usr/lib/ruby/$(PKG_LIBVER)/*/enc/iso_8859_1.so \
		--exclude=usr/lib/ruby/$(PKG_LIBVER)/*/enc/utf_* \
		--exclude=usr/lib/ruby/$(PKG_LIBVER)/*/enc/euc_jp.so \
		-cf - \
		usr/lib/ruby/$(PKG_LIBVER)/*/enc \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-erb/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/erb $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/erb.rb $(1)/usr/lib/ruby/$(PKG_LIBVER)/
endef

define Package/ruby-fiddle/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/fiddle.rb \
		usr/lib/ruby/$(PKG_LIBVER)/fiddle/ \
		usr/lib/ruby/$(PKG_LIBVER)/*/fiddle.so \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-filelib/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/tmpdir.rb \
		usr/lib/ruby/$(PKG_LIBVER)/tempfile.rb \
		usr/lib/ruby/$(PKG_LIBVER)/pathname.rb \
		usr/lib/ruby/$(PKG_LIBVER)/*/pathname.so \
		usr/lib/ruby/$(PKG_LIBVER)/find.rb \
		usr/lib/ruby/$(PKG_LIBVER)/fileutils.rb \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-gdbm/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/*/gdbm.so \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-gems/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/gem $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/ubygems.rb $(1)/usr/lib/ruby/$(PKG_LIBVER)/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rubygems.rb $(1)/usr/lib/ruby/$(PKG_LIBVER)/
	# Remove tests (avoids extra deps)
	$(RM) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rubygems/test_case.rb
	$(RM) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rubygems/package/tar_test_case.rb
	$(RM) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rubygems/installer_test_case.rb
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rubygems $(1)/usr/lib/ruby/$(PKG_LIBVER)/
	$(INSTALL_DIR) $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/specifications/default
	$(INSTALL_DIR) $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/gems
	$(INSTALL_DIR) $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/doc
	$(INSTALL_DIR) $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/cache
	$(INSTALL_DIR) $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/extensions
	$(INSTALL_DIR) $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/build_info
endef

define Package/ruby-io-console/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/*/io/console.so \
		usr/lib/ruby/$(PKG_LIBVER)/io/console/ \
		usr/lib/ruby/gems/$(PKG_LIBVER)/specifications/default/io-console-*.gemspec \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-irb/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/irb $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/irb $(1)/usr/lib/ruby/$(PKG_LIBVER)/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/irb.rb $(1)/usr/lib/ruby/$(PKG_LIBVER)/
endef

define Package/ruby-json/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/json.rb \
		usr/lib/ruby/$(PKG_LIBVER)/json \
		usr/lib/ruby/$(PKG_LIBVER)/*/json \
		usr/lib/ruby/gems/$(PKG_LIBVER)/specifications/default/json-*.gemspec \
	) | ( cd $(1); $(TAR) -xf - )
	rm -rf \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/psych/json
endef

define Package/ruby-logger/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/logger.rb \
		usr/lib/ruby/$(PKG_LIBVER)/syslog/logger.rb \
		usr/lib/ruby/$(PKG_LIBVER)/*/syslog.so \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-math/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/prime.rb \
		usr/lib/ruby/$(PKG_LIBVER)/mathn.rb \
		usr/lib/ruby/$(PKG_LIBVER)/cmath.rb \
		usr/lib/ruby/$(PKG_LIBVER)/*/mathn \
		usr/lib/ruby/$(PKG_LIBVER)/matrix.rb \
		usr/lib/ruby/$(PKG_LIBVER)/matrix \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-minitest/install
	$(INSTALL_DIR) $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/specifications
	$(INSTALL_DIR) $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/gems
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/gems/$(PKG_LIBVER)/specifications/minitest-*.gemspec $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/specifications/
	# Remove tests (avoids extra deps)
	$(RM) -rf $(PKG_INSTALL_DIR)/usr/lib/ruby/gems/$(PKG_LIBVER)/gems/minitest-*/test
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/gems/$(PKG_LIBVER)/gems/minitest-* $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/gems/
endef

define Package/ruby-misc/install
	$(INSTALL_DIR) $(1)/usr/lib
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/English.rb \
		usr/lib/ruby/$(PKG_LIBVER)/abbrev.rb \
		usr/lib/ruby/$(PKG_LIBVER)/base64.rb \
		usr/lib/ruby/$(PKG_LIBVER)/delegate.rb \
		usr/lib/ruby/$(PKG_LIBVER)/e2mmap.rb \
		usr/lib/ruby/$(PKG_LIBVER)/expect.rb \
		usr/lib/ruby/$(PKG_LIBVER)/getoptlong.rb \
		usr/lib/ruby/$(PKG_LIBVER)/open3.rb \
		usr/lib/ruby/$(PKG_LIBVER)/ostruct.rb \
		usr/lib/ruby/$(PKG_LIBVER)/scanf.rb \
		usr/lib/ruby/$(PKG_LIBVER)/securerandom.rb \
		usr/lib/ruby/$(PKG_LIBVER)/set.rb \
		usr/lib/ruby/$(PKG_LIBVER)/shellwords.rb \
		usr/lib/ruby/$(PKG_LIBVER)/tsort.rb \
		usr/lib/ruby/$(PKG_LIBVER)/weakref.rb \
		usr/lib/ruby/$(PKG_LIBVER)/*/continuation.so \
		usr/lib/ruby/$(PKG_LIBVER)/*/coverage.so \
		usr/lib/ruby/$(PKG_LIBVER)/*/etc.so \
		usr/lib/ruby/$(PKG_LIBVER)/*/fcntl.so \
		usr/lib/ruby/$(PKG_LIBVER)/*/fiber.so \
		usr/lib/ruby/$(PKG_LIBVER)/*/pty.so \
		usr/lib/ruby/$(PKG_LIBVER)/*/stringio.so \
		usr/lib/ruby/$(PKG_LIBVER)/*/strscan.so \
	) | ( cd $(1); $(TAR) -xf - )
endef



define Package/ruby-mkmf/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/mkmf.rb \
		usr/lib/ruby/$(PKG_LIBVER)/un.rb \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-multithread/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/monitor.rb \
		usr/lib/ruby/$(PKG_LIBVER)/timeout.rb \
		usr/lib/ruby/$(PKG_LIBVER)/thwait.rb \
		usr/lib/ruby/$(PKG_LIBVER)/mutex_m.rb \
		usr/lib/ruby/$(PKG_LIBVER)/sync.rb \
		usr/lib/ruby/$(PKG_LIBVER)/*/thread.so \
		usr/lib/ruby/$(PKG_LIBVER)/*/io/wait.so \
		usr/lib/ruby/$(PKG_LIBVER)/*/io/nonblock.so \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-net/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/open-uri.rb \
		usr/lib/ruby/$(PKG_LIBVER)/net/* \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-nkf/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/kconv.rb \
		usr/lib/ruby/$(PKG_LIBVER)/*/nkf.so \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-openssl/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/openssl \
		usr/lib/ruby/$(PKG_LIBVER)/openssl.rb \
		usr/lib/ruby/$(PKG_LIBVER)/*/openssl.so \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-optparse/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/optparse.rb \
		usr/lib/ruby/$(PKG_LIBVER)/optionparser.rb \
		usr/lib/ruby/$(PKG_LIBVER)/optparse \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-patterns/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/observer.rb \
		usr/lib/ruby/$(PKG_LIBVER)/singleton.rb \
		usr/lib/ruby/$(PKG_LIBVER)/forwardable.rb \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-powerassert/install
	$(INSTALL_DIR) $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/specifications
	$(INSTALL_DIR) $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/gems
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/gems/$(PKG_LIBVER)/specifications/power_assert-*.gemspec $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/specifications/
	# Remove tests (avoids extra deps)
	$(RM) -rf $(PKG_INSTALL_DIR)/usr/lib/ruby/gems/$(PKG_LIBVER)/gems/power_assert-*/test
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/gems/$(PKG_LIBVER)/gems/power_assert-* $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/gems/
endef

define Package/ruby-prettyprint/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/pp.rb \
		usr/lib/ruby/$(PKG_LIBVER)/prettyprint.rb \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-pstore/install
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/pstore.rb $(1)/usr/lib/ruby/$(PKG_LIBVER)/
endef

define Package/ruby-psych/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/psych \
		usr/lib/ruby/$(PKG_LIBVER)/psych.rb \
		usr/lib/ruby/$(PKG_LIBVER)/*/psych.so \
		usr/lib/ruby/gems/$(PKG_LIBVER)/specifications/default/psych-*.gemspec \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-racc/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/racc \
		usr/lib/ruby/$(PKG_LIBVER)/*/racc/*.so \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-rake/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rake $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rake.rb $(1)/usr/lib/ruby/$(PKG_LIBVER)/
	# Remove tests (avoids extra deps)
	$(RM) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rake/runtest.rb
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rake $(1)/usr/lib/ruby/$(PKG_LIBVER)/
	$(INSTALL_DIR) $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/specifications/default
	$(INSTALL_DIR) $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/gems
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/gems/$(PKG_LIBVER)/specifications/default/rake-*.gemspec \
		$(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/specifications/default/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/gems/$(PKG_LIBVER)/gems/rake-* $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/gems/
endef

define Package/ruby-rbconfig/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/*/rbconfig.rb \
		usr/lib/ruby/$(PKG_LIBVER)/rbconfig/* \
		usr/lib/ruby/$(PKG_LIBVER)/*/rbconfig/*.so \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-rdoc/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rdoc $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ri $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)
	# Remove tests (avoids extra deps)
	$(RM) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rdoc/test_case.rb
	$(RM) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rdoc/markup/formatter_test_case.rb
	$(RM) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rdoc/markup/text_formatter_test_case.rb
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rdoc.rb $(1)/usr/lib/ruby/$(PKG_LIBVER)/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rdoc $(1)/usr/lib/ruby/$(PKG_LIBVER)/
	$(INSTALL_DIR) $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/specifications/default
	$(INSTALL_DIR) $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/gems
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/gems/$(PKG_LIBVER)/specifications/default/rdoc-*.gemspec \
		$(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/specifications/default/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/gems/$(PKG_LIBVER)/gems/rdoc-* \
		$(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/gems/
endef

define Package/ruby-readline/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/*/readline.so \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-rexml/install
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rexml $(1)/usr/lib/ruby/$(PKG_LIBVER)/
endef

define Package/ruby-rinda/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/rinda \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-ripper/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/ripper.rb \
		usr/lib/ruby/$(PKG_LIBVER)/ripper \
		usr/lib/ruby/$(PKG_LIBVER)/*/ripper.so \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-rss/install
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rss $(1)/usr/lib/ruby/$(PKG_LIBVER)/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rss.rb $(1)/usr/lib/ruby/$(PKG_LIBVER)/
endef

define Package/ruby-sdbm/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/*/sdbm.so \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-shell/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/shell.rb \
		usr/lib/ruby/$(PKG_LIBVER)/shell \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-socket/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/ipaddr.rb \
		usr/lib/ruby/$(PKG_LIBVER)/resolv-replace.rb \
		usr/lib/ruby/$(PKG_LIBVER)/resolv.rb \
		usr/lib/ruby/$(PKG_LIBVER)/socket.rb \
		usr/lib/ruby/$(PKG_LIBVER)/*/socket.so \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-testunit/install
	$(INSTALL_DIR) $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/specifications
	$(INSTALL_DIR) $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/gems
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/gems/$(PKG_LIBVER)/specifications/test-unit-*.gemspec $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/specifications/
	# Remove tests (avoids extra deps)
	$(RM) -rf $(PKG_INSTALL_DIR)/usr/lib/ruby/gems/$(PKG_LIBVER)/gems/test-unit-*/test
	$(RM) -rf $(PKG_INSTALL_DIR)/usr/lib/ruby/gems/$(PKG_LIBVER)/gems/test-unit-*/sample
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/gems/$(PKG_LIBVER)/gems/test-unit-* $(1)/usr/lib/ruby/gems/$(PKG_LIBVER)/gems/
endef

define Package/ruby-unicodenormalize/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/unicode_normalize.rb \
		usr/lib/ruby/$(PKG_LIBVER)/unicode_normalize \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-uri/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/uri.rb \
		usr/lib/ruby/$(PKG_LIBVER)/uri \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-webrick/install
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/webrick $(1)/usr/lib/ruby/$(PKG_LIBVER)/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/webrick.rb $(1)/usr/lib/ruby/$(PKG_LIBVER)/
endef

define Package/ruby-xmlrpc/install
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/xmlrpc $(1)/usr/lib/ruby/$(PKG_LIBVER)/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/xmlrpc.rb $(1)/usr/lib/ruby/$(PKG_LIBVER)/
endef

define Package/ruby-yaml/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/yaml \
		usr/lib/ruby/$(PKG_LIBVER)/yaml.rb \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-zlib/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/*/zlib.so \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Build/InstallDev
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		. \
	) | ( cd $(1); $(TAR) -xf - )
endef

$(eval $(call BuildPackage,ruby))
$(eval $(call BuildPackage,libruby))
$(eval $(call BuildPackage,ruby-stdlib))
$(eval $(call BuildPackage,ruby-bigdecimal))
$(eval $(call BuildPackage,ruby-cgi))
$(eval $(call BuildPackage,ruby-csv))
$(eval $(call BuildPackage,ruby-datetime))
$(eval $(call BuildPackage,ruby-dbm))
$(eval $(call BuildPackage,ruby-debuglib))
$(eval $(call BuildPackage,ruby-digest))
$(eval $(call BuildPackage,ruby-drb))
$(eval $(call BuildPackage,ruby-enc))
$(eval $(call BuildPackage,ruby-enc-extra))
$(eval $(call BuildPackage,ruby-erb))
$(eval $(call BuildPackage,ruby-fiddle))
$(eval $(call BuildPackage,ruby-filelib))
$(eval $(call BuildPackage,ruby-gdbm))
$(eval $(call BuildPackage,ruby-gems))
$(eval $(call BuildPackage,ruby-io-console))
$(eval $(call BuildPackage,ruby-irb))
$(eval $(call BuildPackage,ruby-json))
$(eval $(call BuildPackage,ruby-logger))
$(eval $(call BuildPackage,ruby-math))
$(eval $(call BuildPackage,ruby-minitest))
$(eval $(call BuildPackage,ruby-misc))
$(eval $(call BuildPackage,ruby-mkmf))
$(eval $(call BuildPackage,ruby-multithread))
$(eval $(call BuildPackage,ruby-net))
$(eval $(call BuildPackage,ruby-nkf))
$(eval $(call BuildPackage,ruby-openssl))
$(eval $(call BuildPackage,ruby-optparse))
$(eval $(call BuildPackage,ruby-patterns))
$(eval $(call BuildPackage,ruby-powerassert))
$(eval $(call BuildPackage,ruby-prettyprint))
$(eval $(call BuildPackage,ruby-pstore))
$(eval $(call BuildPackage,ruby-psych))
$(eval $(call BuildPackage,ruby-racc))
$(eval $(call BuildPackage,ruby-rake))
$(eval $(call BuildPackage,ruby-rbconfig))
$(eval $(call BuildPackage,ruby-rdoc))
$(eval $(call BuildPackage,ruby-readline))
$(eval $(call BuildPackage,ruby-rexml))
$(eval $(call BuildPackage,ruby-rinda))
$(eval $(call BuildPackage,ruby-ripper))
$(eval $(call BuildPackage,ruby-rss))
$(eval $(call BuildPackage,ruby-sdbm))
$(eval $(call BuildPackage,ruby-shell))
$(eval $(call BuildPackage,ruby-socket))
$(eval $(call BuildPackage,ruby-testunit))
$(eval $(call BuildPackage,ruby-unicodenormalize))
$(eval $(call BuildPackage,ruby-uri))
$(eval $(call BuildPackage,ruby-webrick))
$(eval $(call BuildPackage,ruby-xmlrpc))
$(eval $(call BuildPackage,ruby-yaml))
$(eval $(call BuildPackage,ruby-zlib))
$(eval $(call HostBuild))
