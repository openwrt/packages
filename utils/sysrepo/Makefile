include $(TOPDIR)/rules.mk

PKG_NAME:=sysrepo

PKG_LICENSE:=ASL-2.0
PKG_MAINTAINER:=Mak Krnic <mak.krnic@sartura.hr>

PKG_NAME:=sysrepo
PKG_VERSION:=2016-05-25-1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=0b12938bf5d4bcf6d6ebeb126a2b1f489fa078a7
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/sysrepo/sysrepo.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_SOURCE_VERSION)

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/sysrepo
  SECTION:=util
  CATEGORY:=Utilities
  DEPENDS:=+libyang +libprotobuf +libprotobuf-c +libev +libavl +liblua +swig
  TITLE:=sysrepo
endef

define Package/sysrepo/install
	true
endef

$(eval $(call BuildPackage,sysrepo))
