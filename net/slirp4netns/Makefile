include $(TOPDIR)/rules.mk

PKG_NAME:=slirp4netns
PKG_VERSION:=1.3.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/rootless-containers/slirp4netns/archive/v$(PKG_VERSION)
PKG_HASH:=a3b7c7b593b279c46d25a48b583371ab762968e98b6a46457d8d52a755852eb9

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/slirp4netns
  SECTION:=net
  CATEGORY:=Network
  TITLE:=slirp4netns
  DEPENDS:=@!arc +libslirp +libseccomp +glib2 +libcap
  URL:=https://github.com/rootless-containers/slirp4netns
endef

define Package/slirp4netns/description
  User-mode networking for unprivileged network namespaces
endef

define Package/slirp4netns/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/slirp4netns $(1)/usr/bin/
endef

$(eval $(call BuildPackage,slirp4netns))
