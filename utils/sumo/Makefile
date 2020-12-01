#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sumo
PKG_VERSION:=1.7.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-src-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/sumo
PKG_HASH:=1f7a668568c92d1eeaa0e54a8af45052747accf9ba42983b21e906a80b16a9c2

PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/sumo
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=SUMO - Simulation of Urban MObility
  URL:=https://sumo.dlr.de/
  DEPENDS:=+libxerces-c +zlib
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
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/{activitygen,dfrouter,duarouter,emissionsDrivingCycle,emissionsMap,jtrrouter,marouter,netconvert,netgenerate,od2trips,polyconvert} $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/sumo $(1)/usr/bin/sumo-bin
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) files/sumo.sh $(1)/usr/sbin/sumo
	$(INSTALL_DIR) $(1)/usr/share/sumo
	$(CP) $(PKG_BUILD_DIR)/data $(1)/usr/share/sumo/
endef

$(eval $(call BuildPackage,sumo))
