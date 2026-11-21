include $(TOPDIR)/rules.mk

PKG_NAME:=etckeeper
PKG_VERSION:=1.18.23
PKG_RELEASE:=1
PKG_MAINTAINER:=Rimas Kudelis <rimas@kudelis.lt>

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYRIGHT GPL
PKG_INSTALL:=1
PKG_SOURCE_URL:=https://git.joeyh.name/git/etckeeper.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_SOURCE_DATE:=2025-08-16
PKG_MIRROR_HASH:=b7cd9d25c3297807d69e64064d29336c4c66d45f78578be844f69cb174f7d2cb

include $(INCLUDE_DIR)/package.mk

define Package/etckeeper
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Store your /etc in a git repository
  URL:=https://etckeeper.branchable.com/
  DEPENDS:= \
  +!BUSYBOX_CONFIG_STAT:coreutils-stat \
  +diffutils \
  +findutils-find \
  +git
  PKGARCH:=all
endef

define Package/etckeeper/description
  etckeeper is a tool to let /etc be stored in a VCS repository.
  It hooks into apk to automatically commit changes made to /etc during package upgrades.
  It tracks file metadata that version control systems do not normally support, but that is important for /etc, such as the permissions of /etc/shadow.
  It's quite modular and configurable, while also being simple to use if you understand the basics of working with version control.
  Upstream etckeeper supports several VCS backends, but this package assumes git.
endef

define Package/etckeeper/conffiles
/etc/etckeeper/
/etc/apk/commit_hooks.d/etckeeper
endef

define Package/etckeeper/install
	$(INSTALL_DIR) $(1)/etc/apk
	$(CP) $(PKG_INSTALL_DIR)/etc/etckeeper $(1)/etc/
	$(CP) $(PKG_INSTALL_DIR)/etc/apk/commit_hooks.d $(1)/etc/apk/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/etckeeper $(1)/usr/bin/
endef

$(eval $(call BuildPackage,etckeeper))
