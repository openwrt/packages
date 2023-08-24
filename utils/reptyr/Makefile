include $(TOPDIR)/rules.mk

PKG_NAME:=reptyr
PKG_VERSION:=0.10.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/nelhage/reptyr/archive/
PKG_HASH:=c6ffbc34a511ac00d072219bda30699e51f2f4eb483cbae9e32e981d49e8b380
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/reptyr
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Tool for reparenting running programs
  URL:=https://github.com/nelhage/reptyr
  DEPENDS:=@!(arc||mips||mipsel||mips64||mips64el)
endef

define Package/reptyr/description
  reptyr is a utility for taking an existing running program and attaching it
  to a new terminal. Started a long-running process over ssh, but have to
  leave and don't want to interrupt it? Just start a screen, use reptyr to
  grab it, and then kill the ssh session and head on home.
endef

MAKE_FLAGS+= \
	UNAME_S=Linux \
	PREFIX=/usr

define Package/reptyr/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/reptyr $(1)/usr/bin/
endef

$(eval $(call BuildPackage,reptyr))
