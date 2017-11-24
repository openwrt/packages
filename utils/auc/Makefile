# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=auc
PKG_VERSION:=0.0.6
PKG_RELEASE=1
PKG_LICENSE:=GPL-3.0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/auc
  SECTION:=base
  CATEGORY:=Base system
  TITLE:=Attended sysUpgrade CLI (EXPERIMENTAL)
  DEPENDS:=+attendedsysupgrade-common +libblobmsg-json +libubox +libubus \
           +libuci +libuclient +rpcd-mod-rpcsys
endef

define Package/auc/description
   CLI client for attended-sysupgrade
endef

define Package/auc/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/auc $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,auc))
