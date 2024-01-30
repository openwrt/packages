#
# Copyright (C) 2007-2023 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Author: Michael Geddes

include $(TOPDIR)/rules.mk

PKG_NAME:=zoneinfo
PKG_VERSION:=2023d
PKG_RELEASE:=1

#As i couldn't find real license used "Public Domain"
#as referense to http://www.iana.org/time-zones/repository/tz-link.html
PKG_LICENSE:=Public-Domain

PKG_SOURCE:=tzdata$(PKG_VERSION).tar.gz
PKG_SOURCE_CODE:=tzcode$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.iana.org/time-zones/repository/releases
PKG_HASH:=dbca21970b0a8b8c0ceceec1d7b91fa903be0f6eca5ae732b5329672232a08f3

include $(INCLUDE_DIR)/package.mk

define Download/tzcode
   FILE=$(PKG_SOURCE_CODE)
   URL=$(PKG_SOURCE_URL)
   HASH:=e9a5f9e118886d2de92b62bb05510a28cc6c058d791c93bd6b84d3292c3c161e
endef

$(eval $(call Download,tzcode))

define Package/zoneinfo/Default
  SUBMENU:=Time Zone info
  TITLE:=Zone Information
  SECTION:=utils
  CATEGORY:=Utilities
  MAINTAINER:=Vladimir Ulrich <admin@evl.su>
endef

define Package/zoneinfo-core
$(call Package/zoneinfo/Default)
  TITLE:=Zone Information (core)
endef

define Package/zoneinfo-simple
$(call Package/zoneinfo/Default)
  TITLE:=Zone Information (simple)
  DEPENDS+= +zoneinfo-core
endef

define Package/zoneinfo-africa
$(call Package/zoneinfo/Default)
  TITLE:=Zone Information (Africa)
  DEPENDS+= +zoneinfo-core
endef

define Package/zoneinfo-america
$(call Package/zoneinfo/Default)
  TITLE:=Zone Information (America North/South)
  PROVIDES:=zoneinfo-northamerica zoneinfo-southamerica
  DEPENDS+= +zoneinfo-core
endef

define Package/zoneinfo-poles
$(call Package/zoneinfo/Default)
  TITLE:=Zone Information (Arctic, Antarctic)
  DEPENDS+= +zoneinfo-core
endef

define Package/zoneinfo-asia
$(call Package/zoneinfo/Default)
  TITLE:=Zone Information (Asia)
  DEPENDS+= +zoneinfo-core
endef

define Package/zoneinfo-atlantic
$(call Package/zoneinfo/Default)
  TITLE:=Zone Information (Atlantic Ocean)
  DEPENDS+= +zoneinfo-core
endef

define Package/zoneinfo-australia-nz
$(call Package/zoneinfo/Default)
  TITLE:=Zone Information (Australia-NZ)
  DEPENDS+= +zoneinfo-core
endef

define Package/zoneinfo-pacific
$(call Package/zoneinfo/Default)
  TITLE:=Zone Information (Pacific Ocean)
  DEPENDS+= +zoneinfo-core
endef

define Package/zoneinfo-europe
$(call Package/zoneinfo/Default)
  TITLE:=Zone Information (Europe)
  DEPENDS+= +zoneinfo-core
endef

define Package/zoneinfo-indian
$(call Package/zoneinfo/Default)
  TITLE:=Zone Information (Indian Ocean)
  PROVIDES:=zoneinfo-india
  DEPENDS+= +zoneinfo-core
endef

define Package/zoneinfo-all
$(call Package/zoneinfo/Default)
  TITLE:=Zone Information (all zones)
  DEPENDS:= \
	+zoneinfo-core \
	+zoneinfo-africa \
	+zoneinfo-america \
	+zoneinfo-poles \
	+zoneinfo-asia \
	+zoneinfo-atlantic \
	+zoneinfo-australia-nz \
	+zoneinfo-pacific \
	+zoneinfo-europe \
	+zoneinfo-indian
endef

define Build/Prepare
	(cd $(PKG_BUILD_DIR) && tar -xzf $(DL_DIR)/$(PKG_SOURCE_CODE) && tar -xzf $(DL_DIR)/$(PKG_SOURCE))
endef

define Build/Compile
	CFLAGS="$(HOST_CFLAGS)" \
	$(MAKE) -C $(PKG_BUILD_DIR) -f Makefile \
		$(HOST_CONFIGURE_OPTS) \
		CC="$(HOSTCC)" \
		LD="\$$$$(CC)" \
		CPPFLAGS="$(HOST_CPPFLAGS) -DHAVE_SNPRINTF=1 -DZIC_BLOAT_DEFAULT='\"fat\"'" \
		LDFLAGS="$(HOST_LDFLAGS)" \
		TOPDIR="$(PKG_INSTALL_DIR)" \
		TZDIR="$(PKG_INSTALL_DIR)/zoneinfo" \
		install
endef

define Package/zoneinfo-core/install
	$(INSTALL_DIR) $(1)/usr/share/zoneinfo
	for i in \
		CET CST6CDT EET EST EST5EDT GB-Eire \
		GB    GMT   GMT+0 GMT-0 GMT0  Greenwich  \
		HST   MET   MST   MST7MDT                \
		PRC   PST8PDT ROC ROK     UCT   UTC      \
		Universal W-SU WET Zulu Etc/* zone.tab ; do \
	  $(CP) $(PKG_INSTALL_DIR)/zoneinfo/$$$$i \
	      $(1)/usr/share/zoneinfo ; \
	done
endef

define Package/zoneinfo-all/install
	:
endef

define Package/zoneinfo-simple/install
	$(INSTALL_DIR) $(1)/usr/share/zoneinfo
	for i in Pacific/Honolulu     \
		America/Anchorage   America/Los_Angeles America/Denver   \
		America/Chicago     America/New_York    America/Caracas  \
		America/Sao_Paulo   Europe/London       Europe/Paris     \
		Africa/Cairo        Europe/Moscow       Asia/Dubai       \
		Asia/Karachi        Asia/Dhaka          Asia/Bangkok      \
		Asia/Hong_Kong      Asia/Tokyo          Australia/Darwin \
		Australia/Adelaide  Australia/Brisbane  Australia/Sydney \
		Australia/Perth     Pacific/Noumea ; do \
	  $(CP) $(PKG_INSTALL_DIR)/zoneinfo/$$$$i \
	      $(1)/usr/share/zoneinfo ; \
	done
endef

define Package/zoneinfo-africa/install
	$(INSTALL_DIR) $(1)/usr/share/zoneinfo
	for i in Africa Egypt Libya ; do \
	  $(CP) $(PKG_INSTALL_DIR)/zoneinfo/$$$$i \
	      $(1)/usr/share/zoneinfo ; \
	done
endef

define Package/zoneinfo-america/install
	$(INSTALL_DIR) $(1)/usr/share/zoneinfo
	for i in America Brazil Canada Chile Cuba Jamaica Mexico Navajo US ; do \
	  $(CP) $(PKG_INSTALL_DIR)/zoneinfo/$$$$i \
	      $(1)/usr/share/zoneinfo ; \
	done
endef

define Package/zoneinfo-poles/install
	$(INSTALL_DIR) $(1)/usr/share/zoneinfo
	for i in Antarctica Arctic ; do \
	  $(CP) $(PKG_INSTALL_DIR)/zoneinfo/$$$$i \
	      $(1)/usr/share/zoneinfo ; \
	done
endef

define Package/zoneinfo-asia/install
	$(INSTALL_DIR) $(1)/usr/share/zoneinfo
	for i in Asia Hongkong Iran Israel Japan Singapore ; do \
	  $(CP) $(PKG_INSTALL_DIR)/zoneinfo/$$$$i \
	      $(1)/usr/share/zoneinfo ; \
	done
endef

define Package/zoneinfo-atlantic/install
	$(INSTALL_DIR) $(1)/usr/share/zoneinfo
	for i in Atlantic Iceland ; do \
	  $(CP) $(PKG_INSTALL_DIR)/zoneinfo/$$$$i \
	      $(1)/usr/share/zoneinfo ; \
	done
endef

define Package/zoneinfo-australia-nz/install
	$(INSTALL_DIR) $(1)/usr/share/zoneinfo
	for i in NZ NZ-CHAT Australia ; do \
	  $(CP) $(PKG_INSTALL_DIR)/zoneinfo/$$$$i \
	      $(1)/usr/share/zoneinfo ; \
	done
endef

define Package/zoneinfo-pacific/install
	$(INSTALL_DIR) $(1)/usr/share/zoneinfo
	for i in Pacific Kwajalein ; do \
	  $(CP) $(PKG_INSTALL_DIR)/zoneinfo/$$$$i \
	      $(1)/usr/share/zoneinfo ; \
	done
endef

define Package/zoneinfo-europe/install
	$(INSTALL_DIR) $(1)/usr/share/zoneinfo
	for i in Europe Eire Portugal Poland Turkey ; do \
	  $(CP) $(PKG_INSTALL_DIR)/zoneinfo/$$$$i \
	      $(1)/usr/share/zoneinfo ; \
	done
endef

define Package/zoneinfo-indian/install
	$(INSTALL_DIR) $(1)/usr/share/zoneinfo
	for i in Indian ; do \
	  $(CP) $(PKG_INSTALL_DIR)/zoneinfo/$$$$i \
	      $(1)/usr/share/zoneinfo ; \
	done
endef

$(eval $(call BuildPackage,zoneinfo-simple))
$(eval $(call BuildPackage,zoneinfo-core))
$(eval $(call BuildPackage,zoneinfo-africa))
$(eval $(call BuildPackage,zoneinfo-america))
$(eval $(call BuildPackage,zoneinfo-poles))
$(eval $(call BuildPackage,zoneinfo-asia))
$(eval $(call BuildPackage,zoneinfo-atlantic))
$(eval $(call BuildPackage,zoneinfo-australia-nz))
$(eval $(call BuildPackage,zoneinfo-pacific))
$(eval $(call BuildPackage,zoneinfo-europe))
$(eval $(call BuildPackage,zoneinfo-indian))
$(eval $(call BuildPackage,zoneinfo-all))
