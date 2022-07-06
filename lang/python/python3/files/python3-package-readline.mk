# SPDX-Identifier-License: GPL-2.0-only
#
# Copyright (C) 2021 Alexandru Ardelean <ardeleanalex@gmail.com>
#
#

define Package/python3-readline
$(call Package/python3/Default)
  TITLE:=Python $(PYTHON3_VERSION) readline module
  DEPENDS:=+python3-light +libreadline +libncursesw
endef

$(eval $(call Py3BasePackage,python3-readline, \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/readline.$(PYTHON3_SO_SUFFIX) \
))
