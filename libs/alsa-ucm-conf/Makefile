#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=alsa-ucm-conf
PKG_VERSION:=1.2.5.1
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=ftp://ftp.alsa-project.org/pub/lib/ \
		http://distfiles.gentoo.org/distfiles/
PKG_HASH:=5841a444166dcbf479db751303dbc3556f685085ac7e00f0c9e7755676195d97

PKG_MAINTAINER:=
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/alsa-ucm-conf
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Sound
  TITLE:=ALSA Use Case Manager configuration (and topologies)
  URL:=https://www.alsa-project.org/
  PKGARCH:=all
endef

define Package/alsa-ucm-conf/description
 This is a set of configuration files needed for some ALS utilities like alsactl.
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/alsa-ucm-conf/install
	$(INSTALL_DIR) $(1)/usr/share/alsa
	$(CP) $(PKG_BUILD_DIR)/ucm2 $(1)/usr/share/alsa
endef

$(eval $(call BuildPackage,alsa-ucm-conf))
