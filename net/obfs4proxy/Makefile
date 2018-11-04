#
# Copyright (C) 2018 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=obfs4proxy
PKG_VERSION:=0.0.7
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://git.torproject.org/pluggable-transports/obfs4.git
PKG_SOURCE_VERSION:=8256fac93c2cf79742725e3aaced5bbe3380fd32
PKG_SOURCE_DATE:=20161115
PKG_MIRROR_HASH:=9c504337f7a2b46310083224cf0998fc7645f8af5d50657cf74358d39916eddc

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=git.torproject.org/pluggable-transports/obfs4.git

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/obfs4proxy/Default
  TITLE:=A Tor pluggable transport proxy, implementing obfs4
  URL:=https://gitweb.torproject.org/pluggable-transports/obfs4.git/
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/obfs4proxy
$(call Package/obfs4proxy/Default)
  SECTION:=net
  CATEGORY:=Network
endef

define Package/golang-torproject-pluggable-transports-obfs4-dev
$(call Package/obfs4proxy/Default)
$(call GoPackage/GoSubMenu)
  TITLE+= (source files)
  DEPENDS+= \
    +golang-github-agl-ed25519-dev \
    +golang-github-dchest-siphash-dev \
    +golang-golang-x-crypto-dev \
    +golang-golang-x-net-dev \
    +golang-torproject-pluggable-transports-goptlib-dev
  PKGARCH:=all
endef

define Package/obfs4proxy/Default/description
obfs4proxy is a tool that attempts to circumvent censorship by
transforming the Tor traffic between the client and the bridge. This way
censors, who usually monitor traffic between the client and the bridge,
will see innocent-looking transformed traffic instead of the actual Tor
traffic.

obfs4proxy implements the obfsucation protocols obfs2, obfs3, and obfs4.

It is written in Go and is compliant with the Tor pluggable transports
specification, and its modular architecture allows it to support
multiple pluggable transports.
endef

define Package/obfs4proxy/description
$(call Package/obfs4proxy/Default/description)

This package contains both the client and the bridge in a single
program.
endef

define Package/golang-torproject-pluggable-transports-obfs4-dev/description
$(call Package/obfs4proxy/Default/description)

This package provides the source files for the client/bridge program.
endef

$(eval $(call GoBinPackage,obfs4proxy))
$(eval $(call BuildPackage,obfs4proxy))

$(eval $(call GoSrcPackage,golang-torproject-pluggable-transports-obfs4-dev))
$(eval $(call BuildPackage,golang-torproject-pluggable-transports-obfs4-dev))
