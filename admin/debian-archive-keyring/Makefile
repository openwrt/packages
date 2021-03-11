include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=debian-archive-keyring
PKG_VERSION:=2019.1
PKG_RELEASE:=2

PKG_SOURCE:=debian-archive-keyring_2019.1_all.deb
PKG_SOURCE_URL:=http://ftp.debian.org/debian/pool/main/d/debian-archive-keyring/
PKG_HASH:=9cefd8917f3d97a999c136aa87f04a3024408b5bc1de470de7d6dfa5e4bd4361
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=Unique
PKG_LICENSE_FILES:=usr/share/doc/debian-archive-keyring/copyright

include $(INCLUDE_DIR)/package.mk

define Package/debian-archive-keyring
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Debian Archive keyring
  URL:=https://salsa.debian.org/release-team/debian-archive-keyring
  PKGARCH:=all
endef

define Build/Prepare
	$(AR) p $(DL_DIR)/$(PKG_SOURCE) data.tar.xz | $(TAR) -xJC $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/debian-archive-keyring/install
	$(INSTALL_DIR) $(1)/usr/share/keyrings
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/usr/share/keyrings/*.gpg $(1)/usr/share/keyrings
endef

$(eval $(call BuildPackage,debian-archive-keyring))
