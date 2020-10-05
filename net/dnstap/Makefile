#
# Copyright (C) 2020 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dnstap
PKG_VERSION:=0.2.2
PKG_RELEASE:=1

PKG_SOURCE:=golang-dnstap-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/dnstap/golang-dnstap/archive/v$(PKG_VERSION)/
PKG_HASH:=c7eb42f1f0ca7247b22b774dd78d9874b9db776fa9072f92a5f3a945000b7a60

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/golang-dnstap-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/dnstap/golang-dnstap

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/dnstap
  SECTION:=net
  CATEGORY:=Network
  TITLE:=dnstap command-line tool
  URL:=https://dnstap.info
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/dnstap/description
  The dnstap command-line tool can read, write, and decode
  dnstap data from a running name server or a previously-saved file.
endef

$(eval $(call GoBinPackage,dnstap))
$(eval $(call BuildPackage,dnstap))
