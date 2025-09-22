#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=snort3
PKG_VERSION:=3.9.5.0
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/snort3/snort3/tar.gz/$(PKG_VERSION)?
PKG_HASH:=e2e36a8db2c4c26a6ff58ea58839339260319eba25d0eb901ddb7210f4fa4b4c

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>, John Audia <therealgraysky@proton.me>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:snort:snort

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

SNORT3DEPS:=+libstdcpp +libdaq3 +libdnet +libopenssl +libpcap +libpcre2 \
    +libpthread +libuuid +zlib +libhwloc +libtirpc @HAS_LUAJIT_ARCH +luajit +libatomic \
    +kmod-nft-queue +liblzma +ucode +ucode-mod-fs +ucode-mod-uci

ifeq ($(filter $(ARCH),mips mips64 mipsel powerpc),)
  SNORT3DEPS += +gperftools-runtime
  CMAKE_OPTIONS += -DENABLE_TCMALLOC=ON \
		   -DTCMALLOC_LIBRARIES=$(STAGING_DIR)/usr/lib/libtcmalloc.so

endif

ifeq ($(filter $(ARCH),x86_64 aarch64),$(ARCH))
  CMAKE_OPTIONS += -DHS_INCLUDE_DIRS=$(STAGING_DIR)/usr/include/hs
endif

define Package/snort3
  SUBMENU:=Firewall
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=$(SNORT3DEPS) \
	+TARGET_x86:vectorscan-runtime \
	+TARGET_bcm4908:vectorscan-runtime \
	+TARGET_qualcommax:vectorscan-runtime \
	+TARGET_qualcommbe:vectorscan-runtime \
	+TARGET_bcm27xx_bcm2710:vectorscan-runtime \
	+TARGET_bcm27xx_bcm2711:vectorscan-runtime \
	+TARGET_bcm27xx_bcm2712:vectorscan-runtime \
	+TARGET_armsr_armv8:vectorscan-runtime \
	+TARGET_airoha_an7581:vectorscan-runtime \
	+TARGET_imx_cortexa53:vectorscan-runtime \
	+TARGET_layerscape_armv8_64b:vectorscan-runtime \
	+TARGET_mediatek_filogic:vectorscan-runtime \
	+TARGET_mediatek_mt7622:vectorscan-runtime \
	+TARGET_mvebu_cortexa53:vectorscan-runtime \
	+TARGET_mvebu_cortexa72:vectorscan-runtime \
	+TARGET_rockchip_armv8:vectorscan-runtime \
	+TARGET_sunxi_cortex53:vectorscan-runtime

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
	-DHAVE_LZMA=ON

TARGET_CFLAGS  += -I$(STAGING_DIR)/usr/include/daq3 -I$(STAGING_DIR)/usr/include/tirpc
TARGET_LDFLAGS += -L$(STAGING_DIR)/usr/lib/daq3 -ltirpc

define Package/snort3/conffiles
/etc/config/snort
/etc/snort/
endef

define Package/snort3/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/snort $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/snort2lua $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/u2{boat,spewfoo} $(1)/usr/bin/
	$(INSTALL_BIN) ./files/snort-{mgr,rules} $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/usr/lib/snort
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/snort/daq/daq_{hext,file}.so $(1)/usr/lib/snort/

	$(INSTALL_DIR) $(1)/usr/share/lua
	$(CP) $(PKG_INSTALL_DIR)/usr/include/snort/lua/snort_plugin.lua $(1)/usr/share/lua/

	$(INSTALL_DIR) $(1)/usr/share/snort
	$(INSTALL_CONF) ./files/main.uc $(1)/usr/share/snort/

	$(INSTALL_DIR) $(1)/usr/share/snort/templates
	$(INSTALL_CONF) ./files/{nftables,snort}.uc $(1)/usr/share/snort/templates/

	$(INSTALL_DIR) $(1)/etc/snort/{rules,lists,builtin_rules,so_rules}

	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/usr/etc/snort/*.lua $(1)/etc/snort
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/usr/etc/snort/file_magic.rules $(1)/etc/snort

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/snort.init $(1)/etc/init.d/snort

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/snort.config $(1)/etc/config/snort
endef

$(eval $(call BuildPackage,snort3))
