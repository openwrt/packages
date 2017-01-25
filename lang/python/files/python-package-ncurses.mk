#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python-ncurses
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) ncurses module
  DEPENDS:=+python-light +libncurses
endef

$(eval $(call PyBasePackage,python-ncurses, \
	/usr/lib/python$(PYTHON_VERSION)/curses \
	/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_curses.so \
	/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_curses_panel.so \
))
