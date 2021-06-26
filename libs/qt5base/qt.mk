include $(TOPDIR)/rules.mk

#PKG_NAME:=
PKG_VERSION_API:=5.15
PKG_VERSION_REV:=2
PKG_VERSION:=$(PKG_VERSION_API).$(PKG_VERSION_REV)
PKG_RELEASE:=$(AUTORELEASE)

PKG_SYS_NAME:=$(QT_NAME)-everywhere-src-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_SYS_NAME).tar.xz
PKG_SOURCE_URL:=http://download.qt.io/archive/qt/$(PKG_VERSION_API)/$(PKG_VERSION)/submodules
#PKG_HASH:=

#PKG_MAINTAINER:=
PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SYS_NAME)
HOST_BUILD_DIR=$(BUILD_DIR)/host/$(PKG_SYS_NAME)

HOST_BUILD_PARALLEL:=1
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk

define Package/qt5/Default
	SECTION:=libs
	CATEGORY:=Libraries
	# TITLE:=
	SUBMENU:=Qt
	URL:=http://qt-project.org
endef

define Package/qt5/Default/description
Qt is a cross-platform C++ application framework. Qt's primary feature
is its rich set of widgets that provide standard GUI functionality.
endef

# define Package/qt5/Default/config
# 	source "$(SOURCE)/Config.in"
# endef
