#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=snort3
PKG_VERSION:=3.1.84.0
PKG_RELEASE:=3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/snort3/snort3
PKG_MIRROR_HASH:=ffa69fdd95c55a943ab4dd782923caf31937dd8ad29e202d7fe781373ed84444

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>, John Audia <therealgraysky@proton.me>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:snort:snort

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/snort3
  SUBMENU:=Firewall
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:= \
	    +(TARGET_x86||TARGET_x86_64):hyperscan-runtime \
	    +gperftools-runtime +libstdcpp +libdaq3 +libdnet +libopenssl +libpcap +libpcre2 \
	    +libpthread +libuuid +zlib +libhwloc +libtirpc @HAS_LUAJIT_ARCH +luajit +libatomic \
	    +kmod-nft-queue +liblzma +ucode +ucode-mod-fs +ucode-mod-uci
  TITLE:=Lightweight Network Intrusion Detection System
  URL:=http://www.snort.org/
  MENU:=1
endef

define Package/snort3/description
  Snort is an open source network intrusion detection and prevention system.
  It is capable of performing real-time traffic analysis, alerting, blocking
  and packet logging on IP networks.  It utilizes a combination of protocol
  analysis and pattern matching in order to detect anomalies, misuse and
  attacks.
endef

# Hyperscan only builds for x86
ifdef CONFIG_TARGET_x86_64
	CMAKE_OPTIONS += -DHS_INCLUDE_DIRS=$(STAGING_DIR)/usr/include/hs
endif

CMAKE_OPTIONS += \
	-DUSE_TIRPC:BOOL=YES \
	-DENABLE_STATIC_DAQ:BOOL=NO \
	-DDAQ_INCLUDE_DIR=$(STAGING_DIR)/usr/include/daq3 \
	-DDAQ_LIBRARIES_DIR_HINT:PATH=$(STAGING_DIR)/usr/lib/daq3 \
	-DFLEX_INCLUDES:PATH=$(STAGING_DIR_HOST)/include \
	-DENABLE_COREFILES:BOOL=NO \
	-DENABLE_GDB:BOOL=NO \
	-DMAKE_DOC:BOOL=NO \
	-DMAKE_HTML_DOC:BOOL=NO \
	-DMAKE_PDF_DOC:BOOL=NO \
	-DMAKE_TEXT_DOC:BOOL=NO \
	-DHAVE_LIBUNWIND=OFF \
	-DENABLE_TCMALLOC=ON \
	-DTCMALLOC_LIBRARIES=$(STAGING_DIR)/usr/lib/libtcmalloc.so \
	-DHAVE_LZMA=ON

TARGET_CFLAGS  += -I$(STAGING_DIR)/usr/include/daq3 -I$(STAGING_DIR)/usr/include/tirpc
TARGET_LDFLAGS += -L$(STAGING_DIR)/usr/lib/daq3 -ltirpc

define Package/snort3/conffiles
/etc/config/snort
/etc/snort/
endef

define Package/snort3/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/snort  \
		$(1)/usr/bin/

	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/snort2lua  \
		$(1)/usr/bin/

	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/u2{boat,spewfoo} \
		$(1)/usr/bin/

	$(INSTALL_BIN) \
		./files/snort-{mgr,rules} \
		$(1)/usr/bin/

	$(INSTALL_DIR) $(1)/usr/lib/snort
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/snort/daq/daq_hext.so \
		$(1)/usr/lib/snort/

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/snort/daq/daq_file.so \
		$(1)/usr/lib/snort/

	$(INSTALL_DIR) $(1)/usr/share/lua
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/snort/lua/snort_plugin.lua \
		$(1)/usr/share/lua/

	$(INSTALL_DIR) $(1)/usr/share/snort
	$(INSTALL_CONF) \
		./files/main.uc \
		$(1)/usr/share/snort/

	$(INSTALL_DIR) $(1)/usr/share/snort/templates
	$(INSTALL_CONF) \
		./files/nftables.uc \
		$(1)/usr/share/snort/templates/
	$(INSTALL_CONF) \
		./files/snort.uc \
		$(1)/usr/share/snort/templates/

	$(INSTALL_DIR) $(1)/etc/snort/{rules,lists,builtin_rules,so_rules}

	$(INSTALL_CONF) \
		$(PKG_INSTALL_DIR)/usr/etc/snort/*.lua \
		$(1)/etc/snort
	$(INSTALL_CONF) \
		$(PKG_INSTALL_DIR)/usr/etc/snort/file_magic.rules \
		$(1)/etc/snort

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) \
		./files/snort.init \
		$(1)/etc/init.d/snort

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) \
		./files/snort.config \
		$(1)/etc/config/snort
	
	sed \
		-i \
		-e "/^-- HOME_NET and EXTERNAL_NET/ i -- The values for the two variables HOME_NET and EXTERNAL_NET have been" \
		-e "/^-- HOME_NET and EXTERNAL_NET/ i -- moved to /etc/config/snort, so do not modify them here without good" \
		-e "/^-- HOME_NET and EXTERNAL_NET/ i -- reason.\n" \
		-e 's/^\(HOME_NET\s\+=\)/--\1/g' \
		-e 's/^\(EXTERNAL_NET\s\+=\)/--\1/g' \
		$(1)/etc/snort/snort.lua
	sed \
		-i -e "s/^\\(RULE_PATH\\s\\+=\\).*/\\1 'rules'/g" \
		-e "s/^\\(BUILTIN_RULE_PATH\\s\\+=\\).*/\\1 'builtin_rules'/g" \
		-e "s/^\\(PLUGIN_RULE_PATH\\s\\+=\\).*/\\1 'so_rules'/g" \
		-e "s/^\\(WHITE_LIST_PATH\\s\\+=\\).*/\\1 'lists'/g" \
		-e "s/^\\(BLACK_LIST_PATH\\s\\+=\\).*/\\1 'lists'/g" \
		$(1)/etc/snort/snort_defaults.lua
endef

$(eval $(call BuildPackage,snort3))
