#
# Copyright (C) 2008-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Based on the initial porting done by el1n

include $(TOPDIR)/rules.mk

PKG_NAME:=softethervpn
PKG_VERSION:=4.21-9613
PKG_VERREL:=beta
PKG_VERDATE:=2016.04.24
PKG_RELEASE:=1

PKG_SOURCE:=softether-src-v$(PKG_VERSION)-$(PKG_VERREL).tar.gz
PKG_SOURCE_URL:=http://www.softether-download.com/files/softether/v$(PKG_VERSION)-$(PKG_VERREL)-$(PKG_VERDATE)-tree/Source_Code/
PKG_MD5SUM:=928d882d5fc23e00f0a5fa4ebf292ab9

PKG_BUILD_DIR:=$(BUILD_DIR)/v$(PKG_VERSION)
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/nls.mk 
include $(INCLUDE_DIR)/package.mk

define Package/softethervpn
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  DEPENDS:=+libpthread +librt +libreadline +libopenssl +libncurses +kmod-tun +zlib $(ICONV_DEPENDS)
  TITLE:=Free Cross-platform Multi-protocol VPN server and client
  URL:=http://www.softether.org/
  MAINTAINER:=Federico Di Marco <fededim@gmail.com>
endef

define Package/softethervpn/description
SoftEther VPN ("SoftEther" means "Software Ethernet") is one of the world's most powerful and easy-to-use multi-protocol VPN software developed as an academic 
project from University of Tsukuba, Japan. SoftEther VPN has strong compatibility to today's most popular VPN products among the world. It has the interoperability
with OpenVPN, L2TP, IPsec, EtherIP, L2TPv3, Cisco VPN Routers and MS-SSTP VPN Clients. SoftEther VPN is the world's only VPN software which supports SSL-VPN, 
OpenVPN, L2TP, EtherIP, L2TPv3 and IPsec as a single VPN software. SoftEther VPN is not only an alternative VPN server to existing VPN products (OpenVPN, 
IPsec and MS-SSTP), but has also original strong SSL-VPN protocol to penetrate any kinds of firewalls. Ultra-optimized SSL-VPN Protocol of SoftEther VPN
has very fast throughput, low latency and firewall resistance.
endef


define Package/softethervpn/conffiles
/usr/libexec/softethervpn/vpn_server.config
/usr/libexec/softethervpn/vpn_client.config
/usr/libexec/softethervpn/vpn_bridge.config
/usr/libexec/softethervpn/lang.config
endef


ifeq ($(CONFIG_OPENSSL_WITH_SSL3),y)
	SE_FLAGS=-DSSL3_SUPPORT
endif

ifeq ($(ARCH),mips)
	SE_FLAGS+= -minterlink-mips16
endif

ifeq ($(ARCH),mipsel)
	SE_FLAGS+= -minterlink-mips16
endif


define Build/Configure
	if [ -v CONFIG_64BIT ]; then cp $(PKG_BUILD_DIR)/src/makefiles/linux_64bit.mak $(PKG_BUILD_DIR)/Makefile; else cp $(PKG_BUILD_DIR)/src/makefiles/linux_32bit.mak $(PKG_BUILD_DIR)/Makefile; fi;
endef

define Build/Compile
	# Softether compiles first a tool called hamcorebuilder which is essentially an archiver. Then the compilation calls this archiver to pack all 
	# resource files (*.html, *.config, .txt, readme, languages) it needs to run in an archive file called hamcore.se2. The three executables are then built 
	# and they will have a runtime dependency on this resource archive. By default OpenWRT build process cross compiles all targets in the makefile
	# generating therefore an error when the archive is generated since the executable is crosscompiled to run on the router and instead it is run
	# by the build host. The workaround is to compile the archiver with the host environment, generate the hamcore.se2 archive and cross compile everything
	# again without regenerating the archive.

	# we clean the last cross compiled version
	make -C $(PKG_BUILD_DIR) clean

	# we compile the hamcorebuilder utility and generate hamcore archive using host environment
	make -C $(PKG_BUILD_DIR) src/bin/BuiltHamcoreFiles/unix/hamcore.se2

	# we clean everything, but we save the built hamcore archive and we update its timestamp to avoid rebuilding the archive with cross compiled hamcorebuilder
	mv $(PKG_BUILD_DIR)/src/bin/BuiltHamcoreFiles/unix/hamcore.se2 $(PKG_BUILD_DIR)/src/bin/BuiltHamcoreFiles/unix/hamcore.se2.1
	make -C $(PKG_BUILD_DIR) clean
		mv $(PKG_BUILD_DIR)/src/bin/BuiltHamcoreFiles/unix/hamcore.se2.1 $(PKG_BUILD_DIR)/src/bin/BuiltHamcoreFiles/unix/hamcore.se2
	touch -d "`date -d 1day`" $(PKG_BUILD_DIR)/src/bin/BuiltHamcoreFiles/unix/hamcore.se2

	ls -la $(PKG_BUILD_DIR)/src/bin/BuiltHamcoreFiles/unix

	# we cross compile everything from the scratch
	$(MAKE) \
		$(TARGET_CONFIGURE_OPTS) \
		CCFLAGS="$(SE_FLAGS) -I$(STAGING_DIR)/usr/include $(ICONV_CFLAGS)" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib $(ICONV_LDFLAGS)" \
		-C $(PKG_BUILD_DIR)
endef

define Package/softethervpn/install
	$(INSTALL_DIR) $(1)/usr/libexec/softethervpn
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/vpnserver/vpnserver $(1)/usr/libexec/softethervpn
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/vpnserver/hamcore.se2 $(1)/usr/libexec/softethervpn
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/vpnclient/vpnclient $(1)/usr/libexec/softethervpn
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/vpnbridge/vpnbridge $(1)/usr/libexec/softethervpn
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/vpncmd/vpncmd $(1)/usr/libexec/softethervpn
	$(INSTALL_BIN) files/launcher.sh $(1)/usr/libexec/softethervpn

	$(INSTALL_DATA) files/dummy $(1)/usr/libexec/softethervpn/vpn_server.config
	$(INSTALL_DATA) files/dummy $(1)/usr/libexec/softethervpn/vpn_bridge.config
	$(INSTALL_DATA) files/dummy $(1)/usr/libexec/softethervpn/vpn_client.config
	$(INSTALL_DATA) files/dummy $(1)/usr/libexec/softethervpn/lang.config

	$(INSTALL_DIR) $(1)/usr/bin

	#$(LN) ../../usr/libexec/softethervpn/launcher.sh $(1)/usr/bin/vpnserver
	#$(LN) ../../usr/libexec/softethervpn/launcher.sh $(1)/usr/bin/vpnclient
	#$(LN) ../../usr/libexec/softethervpn/launcher.sh $(1)/usr/bin/vpnbridge
	$(LN) ../../usr/libexec/softethervpn/launcher.sh $(1)/usr/bin/vpncmd

	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/vpnserver.init $(1)/etc/init.d/softethervpnserver
	$(INSTALL_BIN) files/vpnbridge.init $(1)/etc/init.d/softethervpnbridge
	$(INSTALL_BIN) files/vpnclient.init $(1)/etc/init.d/softethervpnclient
endef

$(eval $(call BuildPackage,softethervpn))
