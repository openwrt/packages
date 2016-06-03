include $(TOPDIR)/rules.mk

PKG_NAME:=netopeer2-cli

PKG_LICENSE:=BSD-3-Clause
PKG_MAINTAINER:=Mislav Novakovic <mislav.novakovic@sartura.hr>

PKG_NAME:=netopeer2-cli
PKG_VERSION:=2016-06-03-1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=7062c5d6ae2015586990bf9e8cf34eff4a38685d
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/CESNET/Netopeer2.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_SOURCE_VERSION)

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/netopeer2-cli
  SECTION:=util
  CATEGORY:=Utilities
  DEPENDS:=+libyang +libsysrepo +libnetconf2 +openssl
  TITLE:=Netopeer2 cli
endef

CMAKE_OPTIONS += \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_BUILD_TYPE:STRING=release

CMAKE_SOURCE_DIR=./cli

define Package/netopeer2-cli/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/netopeer2-cli $(1)/bin/
endef

$(eval $(call BuildPackage,netopeer2-cli))
