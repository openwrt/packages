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
	MENU :=0
	DEPENDS := +libjson-c +libpthread
endef

define Package/poprouting/description
Prince is an open source implementation of the PopRouting Algorithm.
It has been developed as a Google Summer of Code Project in collaboration with Freifunk and the University of Trento.

It fetches topology data from a Link State routing deamon(OONF, OLSR, OSPF, etc),
uses the betweenness centrality to optimize the timer's value and pushes back the optimized timer.
Currently it only supports OLSRd2 (aka OONF).
endef


$(eval $(call BuildPackage,poprouting))
