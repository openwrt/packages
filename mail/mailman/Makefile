# 
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mailman
PKG_RELEASE:=1
PKG_SOURCE_URL:=@GNU/$(PKG_NAME)
PKG_VERSION:=2.1.23
PKG_HASH:=b022ca6f8534621c9dbe50c983948688bc4623214773b580c2c78e4a7ae43e69
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_MAINTAINER:=Denis Shulyaka <Shulyaka@gmail.com>
PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=gnu-COPYING-GPL

include $(INCLUDE_DIR)/package.mk

define Package/mailman
  SECTION:=mail
  CATEGORY:=Mail
  TITLE:=The GNU Mailing List Manager
  URL:=http://www.gnu.org/software/mailman/
  DEPENDS:=+postfix +python +uhttpd +python-dns
endef

define Package/mailman/description
 Mailman is free software for managing electronic mail discussion and e-newsletter lists.
endef

prefix=/usr/local/mailman

define Package/mailman/conffiles
$(prefix)/Mailman/mm_cfg.py
endef

CONFIGURE_ARGS += \
	--prefix="$(prefix)" \
	--exec-prefix="$(prefix)" \
	--with-username="root" \
	--with-groupname="root" \
	--with-mail-gid="nogroup" \
	--with-cgi-gid="root" \
	--without-permcheck \

define Build/Compile
endef

define Package/mailman/install
	$(INSTALL_DIR) $(1)$(prefix)
	cd $(PKG_BUILD_DIR); $(MAKE) DESTDIR=$(1) install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mailman.init $(1)/etc/init.d/mailman
	$(INSTALL_DIR) $(1)/usr/www
	ln -s $(prefix)/cgi-bin/ $(1)/usr/www/mailman
	ln -s $(prefix)/archives/public/ $(1)/usr/www/pipermail
	ln -s $(prefix)/icons $(1)/usr/www/icons
endef

define Package/mailman/postinst
#!/bin/sh
# check if we are on real system
if [ -z "$${IPKG_INSTROOT}" ]; then

 if [ `postconf alias_maps | grep -ci mailman` -eq 0 ]
 then
  postconf -e "`postconf alias_maps`, cdb:$(prefix)/data/aliases"
 fi
 cd $(prefix)
 hostname=`cat /proc/sys/kernel/hostname`
 if [ ! -f data/aliases ]
 then
  ./bin/genaliases
 fi
 newaliases
 if [ `grep -c DEFAULT_URL_HOST Mailman/mm_cfg.py` -eq 0 ]
 then
  echo "DEFAULT_EMAIL_HOST = '$$hostname'" >> Mailman/mm_cfg.py
  echo "DEFAULT_URL_HOST = '$$hostname'" >> Mailman/mm_cfg.py
  echo "add_virtualhost(DEFAULT_URL_HOST, DEFAULT_EMAIL_HOST)" >> Mailman/mm_cfg.py
  echo "QRUNNERS.remove(('NewsRunner',1))" >> Mailman/mm_cfg.py
 fi
 if [ `./bin/list_lists | grep -ci mailman` -eq 0 ]
 then
  ./bin/newlist --urlhost=$$hostname --emailhost=$$hostname --quiet mailman root@$$hostname mailman
  ./bin/config_list -i data/sitelist.cfg mailman
  echo "NOTE: A default site-wide mailing list Mailman with password 'mailman' has been created. Please review it and change the password."
  ./bin/mmsitepass mailman
  echo "NOTE: The default site password 'mailman' has been created."
 fi
 # /etc/init.d/mailman enable
 if [ `ps | grep "mailman/bin/qrunner" | grep -cv grep` -gt 0 ]
 then
  $(prefix)/bin/mailmanctl -q restart
 fi
 if [ `grep -c mailman /etc/config/uhttpd` -eq 0 ]
 then #we assume that the server is not configured yet, thus print out some help for the first time:
  echo "NOTE: Please set the site password using $(prefix)/bin/mmsitepass <your-site-password>"
  echo "Please add uhttpd config section to your /etc/config/uhttpd like this:"
  echo "config uhttpd mailman"
  echo "	list listen_http	0.0.0.0:80"
  echo "	option home		/usr/www"
  echo "	option cgi_prefix	/mailman"
  echo "	no_symlinks		0"
  echo "Don't forget to setup firewall for accessing this website!"
  echo "To add a mailing list go to http://$$hostname/mailman/create."
 fi
fi
endef

define Package/mailman/prerm
#!/bin/sh
# check if we are on real system
if [ -z "$${IPKG_INSTROOT}" ]; then

 if [ `ps | grep "mailman/bin/qrunner" | grep -cv grep` -gt 0 ]
 then
  $(prefix)/bin/mailmanctl stop
 fi
fi
endef

$(eval $(call BuildPackage,mailman))
