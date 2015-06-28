#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sumo
PKG_VERSION:=0.23.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-src-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/sumo
PKG_MD5SUM:=0df95a449d44808b8d3677af086e1af1
PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--with-xerces=$(STAGING_DIR)/usr \
	--disable-debug \
	--disable-dependency-tracking \
	--disable-silent-rules

define Package/sumo
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=SUMO - Simulation of Urban MObility
  URL:=http://sumo-sim.org/
  DEPENDS:=+libstdcpp +libxerces-c
endef

define Package/sumo/description
  SUMO is a free and open traffic simulation suite which is available since 2001.
  SUMO allows modelling of intermodal traffic systems including road vehicles,
  public transport and pedestrians. Included with SUMO is a wealth of supporting
  tools which handle tasks such as route finding, visualization, network import
  and emission calculation. SUMO can be enhanced with custom models and provides
  various APIs to remotely control the simulation.
endef

define Package/sumo/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/{activitygen,dfrouter,duarouter,emissionsDrivingCycle,emissionsMap,jtrrouter,marouter,netconvert,netgenerate,od2trips,polyconvert,TraCITestClient} $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/sumo $(1)/usr/bin/sumo-bin
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) files/sumo.sh $(1)/usr/sbin/sumo
	$(INSTALL_DIR) $(1)/usr/share/sumo
	$(CP) $(PKG_BUILD_DIR)/data $(1)/usr/share/sumo/
endef

$(eval $(call BuildPackage,sumo))
