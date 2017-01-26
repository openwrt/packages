include $(TOPDIR)/rules.mk

PKG_NAME:=prince
PKG_VERSION:=v0.2
PKG_RELEASE:=2

PKG_BUILD_DIR:=$(BUILD_DIR)/prince-$(PKG_VERSION)
PKG_USE_MIPS16:=0
PKG_SOURCE_PROTO:=git
PKG_SOURCE:=prince-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/gabri94/poprouting.git
PKG_SOURCE_VERSION:=v0.2
PKG_SOURCE_SUBDIR:=prince-v0.2
include $(INCLUDE_DIR)/package.mk

define Package/prince
	SECTION :=net
	CATEGORY :=Network
	SUBMENU :=Routing and Redirection
	Mantainer :=Gabriele Gemmi <gabriel@autistici.org>
	TITLE :=PopRouting daemon
	URL :=https://github.com/gabri94/poprouting
	MENU :=0
	DEPENDS := +libjson-c +libpthread
endef

define Package/prince/description
Prince is an open source implementation of the PopRouting Algorithm.
It has been developed as a Google Summer of Code Project in collaboration with Freifunk and the University of Trento.

It work by fetching topology data from a Link State routing demon(OONF, OLSR, OSPF, etc),
calculating the betweenness centrality using the topology, then using these data
the timer's value are optimized. Finally the timers are pushed back to the routing demon.
Currently it only supports OLSRd2 (aka OONF).
endef

define Package/prince/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/graph-parser_c/build/lib/libgraphcparser.so $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/prince/build/prince_c $(1)/usr/sbin/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/prince/build/libprince_oonf.so $(1)/usr/lib/
endef


$(eval $(call BuildPackage,prince))
