#
# This software is licensed under the Public Domain.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=xdp-tools
PKG_SOURCE_DATE:=2021-02-12
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/xdp-project/xdp-tools.git
PKG_SOURCE_VERSION:=f05d1cf74732be3a008bba14d1862e58268a11a4
PKG_MIRROR_HASH:=16beae6e5225d96e5d1dc6a5c9986dbe697491fbc948b323ed0daca0212c87db

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/xdp-tools
  SECTION:=net
  CATEGORY:=Network
  TITLE:=XDP Tools
  URL:=https://github.com/xdp-project/xdp-tools.git
  DEPENDS:=+libbpf +libpcap
endef

define Package/xdp-tools/description
	Utilities and example programs for use with XDP.
endef

TARGET_CPPFLAGS+=-I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/include
TARGET_LDFLAGS+=-L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib

ifeq ($(CONFIG_BIG_ENDIAN),y)
CONFIGURE_VARS+= \
	BPF_TARGET=bpfeb
else
CONFIGURE_VARS+= \
	BPF_TARGET=bpfel
endif

define Package/xdp-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/xdp-loader/xdp-loader $(1)/usr/bin/xdp-loader
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/xdp-dump/xdpdump $(1)/usr/bin/xdpdump
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/xdp-filter/xdp-filter $(1)/usr/bin/xdp-filter
endef

$(eval $(call BuildPackage,xdp-tools))
