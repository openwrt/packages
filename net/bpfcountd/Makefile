# SPDX-License-Identifier: MIT
# Copyright (C) 2022 Linus Lüssing <linus.luessing@c0d3.blue>

include $(TOPDIR)/rules.mk

PKG_NAME:=bpfcountd
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2021-06-26
PKG_SOURCE_URL=https://github.com/lemoer/bpfcountd.git
PKG_SOURCE_VERSION:=8b1aeb18d686815f93e2bfe976e536c5699d6371
PKG_MIRROR_HASH:=d386f41da2499a453fbd6b14321bb1ce60779952a80e703fdb5532de2c7b2ea0

PKG_MAINTAINER:=Linus Lüssing <linus.luessing@c0d3.blue>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/bpfcountd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Berkeley Packet Filter Counting Daemon
  DEPENDS:=+libpcap
endef

define Package/bpfcountd/description
  bpfcountd was created to obtain packet statistics in larger networks
  without stressing the cpu resources. bpfcountd will count the amount
  of packages and bytes over time (for each defined rule). The rules
  are defined using the tcpdump filter syntax (bpf). The collected
  data is provided on a unix socket in plaintext.
endef

define Package/bpfcountd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bpfcountd $(1)/usr/sbin/
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,bpfcountd))
