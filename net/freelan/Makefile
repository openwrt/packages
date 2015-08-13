#
# Copyright (C) 2015 Rolf Leggewie
# Copyright (C) Julien Kauffmann
# Copyright (C) Champtar@Github
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=freelan
PKG_VERSION:=2015-08-01
PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git://github.com/freelan-developers/freelan-all.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
#PKG_SOURCE_VERSION:=2.0
PKG_SOURCE_VERSION:=3177dd8b21540d8c8d8c3472d85ad00ae4bc39d6
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

PKG_LICENSE:=GPLv3+
PKG_LICENSE_FILES:=

PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

PKG_MAINTAINER:="Julien Kauffmann"

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/scons.mk

define Package/freelan
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  DEPENDS:=+boost-date_time +boost-filesystem +boost-iostreams +boost-program_options +boost-system +boost-thread +kmod-tun +libopenssl +libstdcpp +libiconv +libcurl
  TITLE:=Highly-configurable peer-to-peer VPN software
  URL:=http://www.freelan.org
endef

define Package/freelan/description
	A free, open-source, multi-platform, highly-configurable and peer-to-peer VPN software, designed to easily connect remote hosts and mainly focused on security and performance.
endef

TARGET_CFLAGS += -Wno-error=cpp
TARGET_CFLAGS += -Wno-error=return-type

SCONS_VARS += \
	CXXFLAGS="$$$$CXXFLAGS -Wno-missing-field-initializer" \
	LIBS="iconv" \
	LINKFLAGS="$(TARGET_LDFLAGS) $(EXTRA_LDFLAGS)" \
	FREELAN_NO_GIT=1 \
	FREELAN_NO_GIT_VERSION="$(PKG_VERSION)-$(PKG_SOURCE_VERSION)"

SCONS_OPTIONS = "--mode=release"

define Package/freelan/install
	$(INSTALL_DIR) \
		$(1)/usr/bin \
		$(1)/etc/freelan \
		$(1)/etc/init.d

	# copying binary
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/freelan \
		$(1)/usr/bin/freelan

	# copying configuration
	#$(INSTALL_CONF) \
	#	$(PKG_BUILD_DIR)/freelan/config/* \
	#	$(1)/etc/freelan

	# creating service
	$(INSTALL_BIN) \
		files/freelan.init \
		$(1)/etc/init.d/freelan
endef

define Package/freelan/conffiles
	/etc/freelan
endef

$(eval $(call BuildPackage,freelan))
