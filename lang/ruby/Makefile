#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

#
# To Do:
#  - split up encodings
#  - allow selection of either native or pure version of a library where supported
#  +-> some native libraries are probably only supported if ruby-dl is enabled
# anything else?

include $(TOPDIR)/rules.mk

PKG_NAME:=ruby
PKG_VERSION:=2.1.2
PKG_RELEASE:=1

PKG_LIBVER:=2.1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://cache.ruby-lang.org/pub/ruby/$(PKG_LIBVER)/
PKG_MD5SUM:=ed9b8565bdeccb401d628ec8d54a0774
PKG_MAINTAINER:=Luiz Angelo Daros de Luca <luizluca@gmail.com>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILE:=COPYING

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
 Ruby is the interpreted scripting language for quick and  easy
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

# Ongoing work to break up ruby's standard library into coherent pieces
# with minimal dependencies between them

define Package/ruby-core
$(call Package/ruby/Default)
  TITLE:=Ruby standard libraries
  DEPENDS:=ruby +libdb47 +libffi
endef

define Package/ruby-cgi
$(call Package/ruby/Default)
  TITLE:=Ruby CGI support toolkit
  DEPENDS:=ruby
endef

define Package/ruby-dl
$(call Package/ruby/Default)
  TITLE+= (dynamic linker support) (adds 5MB+)
  DEPENDS:=ruby
endef

define Package/ruby-enc
$(call Package/ruby/Default)
  TITLE+= (character re-coding library) (adds 2MB+)
  DEPENDS:=ruby
endef

define Package/ruby-erb
$(call Package/ruby/Default)
  TITLE+= (embedded interpreter)
  DEPENDS:=ruby
endef

define Package/ruby-gdbm
$(call Package/ruby/Default)
  TITLE:=Ruby support for gdbm
  DEPENDS:=ruby +libgdbm
endef

define Package/ruby-gems
$(call Package/ruby/Default)
  TITLE:=Ruby gems packet management
  DEPENDS:=ruby +ruby-yaml +ruby-zlib +ruby-openssl +ruby-webrick +ruby-erb
endef

define Package/ruby-irb
$(call Package/ruby/Default)
  TITLE+= (interactive shell)
  DEPENDS:=ruby +ruby-core
endef

define Package/ruby-json
$(call Package/ruby/Default)
  TITLE:=Ruby support for JSON
  DEPENDS:=ruby
endef

define Package/ruby-ncurses
$(call Package/ruby/Default)
  TITLE:=Ruby support for ncurses
  DEPENDS:=ruby +libncurses +libncursesw
endef

define Package/ruby-nkf
$(call Package/ruby/Default)
  TITLE:=Ruby Network Kanji Filter
  DEPENDS:=ruby
endef

define Package/ruby-openssl
$(call Package/ruby/Default)
  TITLE:=Ruby support for openssl
  DEPENDS:=ruby +libopenssl
endef

define Package/ruby-rdoc
$(call Package/ruby/Default)
  TITLE+= (documentation generator)
  DEPENDS:=ruby
endef

define Package/ruby-rake
$(call Package/ruby/Default)
  TITLE+=Ruby Rake (make replacement)
  DEPENDS:=ruby
endef

define Package/ruby-readline
$(call Package/ruby/Default)
  TITLE:=Ruby support for readline
  DEPENDS:=ruby +libncurses +libreadline
endef

define Package/ruby-rexml
$(call Package/ruby/Default)
  TITLE:=Ruby XML toolkit
  DEPENDS:=ruby
endef

define Package/ruby-rss
$(call Package/ruby/Default)
  TITLE:=Ruby RSS toolkit
  DEPENDS:=ruby
endef

define Package/ruby-unit
$(call Package/ruby/Default)
  TITLE:=Ruby unit testing toolkit
  DEPENDS:=ruby
endef

define Package/ruby-webrick
$(call Package/ruby/Default)
  TITLE:=Ruby Web server toolkit
  DEPENDS:=ruby
endef

define Package/ruby-xmlrpc
$(call Package/ruby/Default)
  TITLE:=Ruby XML-RPC toolkit
  DEPENDS:=ruby
endef

define Package/ruby-yaml
$(call Package/ruby/Default)
  TITLE:=Ruby YAML toolkit
  DEPENDS:=ruby
endef

define Package/ruby-zlib
$(call Package/ruby/Default)
  TITLE:=Ruby support for zlib
  DEPENDS:=ruby +zlib
endef

HOST_CONFIGURE_ARGS += \
	--disable-install-doc \
	--disable-install-rdoc \
	--disable-install-capi \
	--with-static-linked-ext \

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--disable-rpath \
	--enable-ipv6 \
	--with-ruby-version=minor \
	--with-iconv-dir=$(ICONV_PREFIX) \

TARGET_LDFLAGS += -L$(PKG_BUILD_DIR)

MAKE_FLAGS += \
	DESTDIR="$(PKG_INSTALL_DIR)" \
	SHELL="/bin/bash"

define Package/ruby/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ruby $(1)/usr/bin/
endef

define Package/libruby/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libruby.so.* $(1)/usr/lib/
endef

define Package/ruby-core/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby $(1)/usr/lib/
	rm -rf	\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/*/curses.so \
		\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/*/gdbm.so \
		\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/kconv.rb \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/*/nkf.so \
		\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/digest \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/digest.rb \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/*/digest \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/*/digest.so \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/openssl \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/openssl.rb \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/*/openssl.so \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/drb/ssl.rb \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/net/https.rb \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/webrick/ssl.rb \
		\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/*/dl.so \
		\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/*/enc \
		\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/*/readline.so \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/irb/completion.rb \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/irb/ext/save-history.rb \
		\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/*/zlib.so \
		\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/erb.rb \
		\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/json.rb \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/json \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/*/json \
		\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/irb.rb \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/irb \
		\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/rdoc \
		\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/rake.rb \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/rake \
		\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/rubygems.rb \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/rubygems \
		\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/cgi.rb \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/cgi \
		\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/rexml \
		\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/rss \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/rss.rb \
		\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/test \
		\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/webrick \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/webrick.rb \
		\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/xmlrpc \
		\
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/yaml \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/yaml.rb \
		$(1)/usr/lib/ruby/$(PKG_LIBVER)/*/syck.so \

	find $(1) -name '*.h' | xargs rm -f
endef

define Package/ruby-cgi/install
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/cgi $(1)/usr/lib/ruby/$(PKG_LIBVER)/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/cgi.rb $(1)/usr/lib/ruby/$(PKG_LIBVER)/
endef

define Package/ruby-dl/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/*/dl.so \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-enc/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/*/enc \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-erb/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/erb $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/erb.rb $(1)/usr/lib/ruby/$(PKG_LIBVER)/
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
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rubygems.rb $(1)/usr/lib/ruby/$(PKG_LIBVER)/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rubygems $(1)/usr/lib/ruby/$(PKG_LIBVER)/
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
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-ncurses/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/*/curses.so \
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
		usr/lib/ruby/$(PKG_LIBVER)/digest \
		usr/lib/ruby/$(PKG_LIBVER)/digest.rb \
		usr/lib/ruby/$(PKG_LIBVER)/*/digest.so \
		usr/lib/ruby/$(PKG_LIBVER)/*/digest/*.so \
		usr/lib/ruby/$(PKG_LIBVER)/openssl \
		usr/lib/ruby/$(PKG_LIBVER)/openssl.rb \
		usr/lib/ruby/$(PKG_LIBVER)/*/openssl.so \
		usr/lib/ruby/$(PKG_LIBVER)/drb/ssl.rb \
		usr/lib/ruby/$(PKG_LIBVER)/net/https.rb \
	) | ( cd $(1); $(TAR) -xf - )
endef

define Package/ruby-rdoc/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rdoc $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ri $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rdoc $(1)/usr/lib/ruby/$(PKG_LIBVER)/
endef

define Package/ruby-rake/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rake $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rake.rb $(1)/usr/lib/ruby/$(PKG_LIBVER)/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rake $(1)/usr/lib/ruby/$(PKG_LIBVER)/
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


define Package/ruby-rss/install
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rss $(1)/usr/lib/ruby/$(PKG_LIBVER)/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/rss.rb $(1)/usr/lib/ruby/$(PKG_LIBVER)/
endef

define Package/ruby-unit/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/testrb $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/test $(1)/usr/lib/ruby/$(PKG_LIBVER)/
endef

define Package/ruby-webrick/install
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/webrick $(1)/usr/lib/ruby/$(PKG_LIBVER)/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/webrick.rb $(1)/usr/lib/ruby/$(PKG_LIBVER)/
endef

define Package/ruby-xmlrpc/install
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(PKG_LIBVER)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ruby/$(PKG_LIBVER)/xmlrpc $(1)/usr/lib/ruby/$(PKG_LIBVER)/
endef

define Package/ruby-yaml/install
	( cd $(PKG_INSTALL_DIR); $(TAR) -cf - \
		usr/lib/ruby/$(PKG_LIBVER)/yaml \
		usr/lib/ruby/$(PKG_LIBVER)/yaml.rb \
		usr/lib/ruby/$(PKG_LIBVER)/*/syck.so \
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
$(eval $(call BuildPackage,ruby-core))
$(eval $(call BuildPackage,ruby-cgi))
$(eval $(call BuildPackage,ruby-dl))
$(eval $(call BuildPackage,ruby-enc))
$(eval $(call BuildPackage,ruby-erb))
$(eval $(call BuildPackage,ruby-gdbm))
$(eval $(call BuildPackage,ruby-gems))
$(eval $(call BuildPackage,ruby-json))
$(eval $(call BuildPackage,ruby-irb))
$(eval $(call BuildPackage,ruby-ncurses))
$(eval $(call BuildPackage,ruby-nkf))
$(eval $(call BuildPackage,ruby-openssl))
$(eval $(call BuildPackage,ruby-rake))
$(eval $(call BuildPackage,ruby-rdoc))
$(eval $(call BuildPackage,ruby-readline))
$(eval $(call BuildPackage,ruby-rexml))
$(eval $(call BuildPackage,ruby-rss))
$(eval $(call BuildPackage,ruby-unit))
$(eval $(call BuildPackage,ruby-webrick))
$(eval $(call BuildPackage,ruby-xmlrpc))
$(eval $(call BuildPackage,ruby-yaml))
$(eval $(call BuildPackage,ruby-zlib))
$(eval $(call HostBuild))
