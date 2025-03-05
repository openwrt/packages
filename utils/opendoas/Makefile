include $(TOPDIR)/rules.mk

PKG_NAME:=opendoas
PKG_VERSION:=6.8.2
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/Duncaen/OpenDoas/releases/download/v$(PKG_VERSION)
PKG_HASH:=4e98828056d6266bd8f2c93e6ecf12a63a71dbfd70a5ea99ccd4ab6d0745adf0

PKG_MAINTAINER:=Michal Vasilek <michal.vasilek@nic.cz>
PKG_LICENSE:=ISC BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/opendoas
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Portable OpenBSD doas to execute commands as another user
  URL:=https://github.com/Duncaen/OpenDoas
  DEPENDS:=+BUSYBOX_CONFIG_PAM:libpam
endef

define Package/opendoas/description
 OpenDoas: a portable version of OpenBSD's doas command

 doas is a minimal replacement for the venerable sudo. It was initially
 written by Ted Unangst of the OpenBSD project to provide 95% of the features
 of sudo with a fraction of the codebase.
endef

CONFIGURE_ARGS += $(if $(CONFIG_BUSYBOX_CONFIG_PAM),--with,--without)-pam

define Package/opendoas/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/doas $(1)/usr/bin/
endef

$(eval $(call BuildPackage,opendoas))
