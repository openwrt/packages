include $(TOPDIR)/rules.mk

PKG_NAME:=sshpass
PKG_VERSION:=1.06
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/sshpass
PKG_HASH:=c6324fcee608b99a58f9870157dfa754837f8c48be3df0f5e2f3accf145dee60

PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/sshpass
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Non-interactive ssh password auth
  URL:=https://sourceforge.net/projects/sshpass/
endef

define Package/sshpass/description
  Sshpass is a tool for non-interactively performing password authentication
  with SSH's so-called "interactive keyboard password authentication". Most user
  should use SSH's more secure public-key authentication instead.
endef

define Package/sshpass/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/sshpass $(1)/usr/bin
endef

$(eval $(call BuildPackage,sshpass))
