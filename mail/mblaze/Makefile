include $(TOPDIR)/rules.mk

PKG_NAME:=mblaze
PKG_VERSION:=1.2
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://leahneukirchen.org/releases
PKG_HASH:=50c164c88cc83b4f52691341ee14060da5a6f1859e86aa73ff595de4b410037f

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_MAINTAINER:=Michal Vasilek <michal.vasilek@nic.cz>
PKG_LICENSE:=Public-Domain MIT
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/mblaze
  SECTION:=mail
  CATEGORY:=Mail
  TITLE:=Unix utilities to deal with Maildir
  URL:=https://github.com/leahneukirchen/mblaze
endef

define Package/mblaze/description
  The mblaze message system is a set of Unix utilities for processing
  and interacting with mail messages which are stored in maildir folders.
endef

MAKE_FLAGS += \
	OS="Linux"

define Package/mblaze/install
	$(INSTALL_DIR) $(1)/usr
	$(CP) $(PKG_INSTALL_DIR)/usr/local/bin $(1)/usr
endef

$(eval $(call BuildPackage,mblaze))
