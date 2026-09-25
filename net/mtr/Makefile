#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mtr
PKG_VERSION:=0.95
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/traviscross/mtr/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=12490fb660ba5fb34df8c06a0f62b4f9cbd11a584fc3f6eceda0a99124e8596f

PKG_MAINTAINER:=Jonathan McCrohan <jmccrohan@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:matt_kimball_and_roger_wolff:mtr

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_BUILD_FLAGS:=gc-sections

CONFIGURE_ARGS += \
	--without-gtk \
	$(call autoconf_bool,CONFIG_IPV6,ipv6)

include $(INCLUDE_DIR)/package.mk

define Package/mtr/Default
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+libncurses
	TITLE:=Full screen ncurses traceroute tool
	URL:=https://www.bitwizard.nl/mtr/
	PROVIDES:=mtr
endef

define Package/mtr-nojson
	$(Package/mtr/Default)
	TITLE+= Without JSON
	VARIANT:=nojson
	DEFAULT_VARIANT:=1
endef

define Package/mtr-json
	$(Package/mtr/Default)
	TITLE+= With JSON
	VARIANT:=json
	DEPENDS+=+jansson
endef

ifeq ($(BUILD_VARIANT),nojson)
	CONFIGURE_ARGS += --without-jansson
endif

define Package/mtr/description
	mtr combines the functionality of the 'traceroute' and 'ping' programs
	in a single network diagnostic tool.
	As mtr starts, it investigates the network connection between the host
	mtr runs on and a user-specified destination host. After it
	determines the address of each network hop between the machines,
	it sends a sequence ICMP ECHO requests to each one to determine the
	quality of the link to each machine. As it does this, it prints
	running statistics about each machine.
endef

TARGET_LDFLAGS += -Wl,--as-needed

CONFIGURE_VARS += ac_cv_lib_cap_cap_set_proc=no

define Package/mtr/install/Default
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/mtr $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/mtr-packet $(1)/usr/sbin/
endef

Package/mtr-nojson/install = $(Package/mtr/install/Default)
Package/mtr-json/install = $(Package/mtr/install/Default)

$(eval $(call BuildPackage,mtr-nojson))
$(eval $(call BuildPackage,mtr-json))
