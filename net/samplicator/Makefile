include $(TOPDIR)/rules.mk

PKG_NAME:=samplicator
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/sleinen/samplicator.git
PKG_SOURCE_DATE:=2021-10-11
PKG_SOURCE_VERSION:=ceeb1d280188c155b71d819282490be86190f6f6
PKG_MIRROR_HASH:=dac8a013f6dfff83dd8f0551ad058e149679339cd0f867c11b2357ab36b71730

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_REMOVE_FILES:=autogen.sh
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/samplicator
  SECTION:=net
  CATEGORY:=Network
  TITLE:=UDP Samplicator
  URL:=https://github.com/sleinen/samplicator
endef

define Package/samplicator/description
  Send copies of (UDP) datagrams to multiple receivers,
  with optional sampling and spoofing.
endef

define Package/samplicator/conffiles
/etc/samplicator.conf
endef

define Package/samplicator/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/samplicate $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/samplicator.init $(1)/etc/init.d/samplicator
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) ./files/samplicator.conf $(1)/etc/
endef

$(eval $(call BuildPackage,samplicator))
