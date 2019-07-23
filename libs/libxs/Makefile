#
# Copyright (c) 2016-2019  Moddable Tech, Inc.
#
#   This file is part of the Moddable SDK Tools.
# 
#   The Moddable SDK Tools is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
# 
#   The Moddable SDK Tools is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with the Moddable SDK Tools.  If not, see <http://www.gnu.org/licenses/>.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libxs
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Brian Friedkin <brian@moddable.tech>
PKG_LICENSE:=GPL-3.0-or-later LGPL-3.0-or-later
PKG_LICENSE_FILES:=licenses/NOTICE licenses/gpl-3.0.txt licenses/lgpl-3.0.txt

DEBUG?=1
INSTRUMENT?=1

include $(INCLUDE_DIR)/package.mk

define Package/libxs/preinst
endef

define Package/libxs
	SECTION:=libraries
	CATEGORY:=Libraries
	TITLE:=Moddable SDK XS JavaScript Engine
	URL:=https://www.moddable.com/
endef

define Package/libxs/description
Use this package to build the XS JavaScript engine

XS is the JavaScript engine at the core of Moddable applications and tools

This package requires a separate download of the Moddable SDK: 
   https://github.com/Moddable-OpenSource/moddable
   
This package also requires one-time Linux host setup: 
   https://github.com/Moddable-OpenSource/moddable/blob/public/documentation/Moddable%20SDK%20-%20Getting%20Started.md#host-linux

endef

define Build/Clean
	@if [ "$(MODDABLE)" = "" ]; then\
        echo -e "\n# Error: MODDABLE environment variable not set!\n# Visit https://github.com/Moddable-OpenSource/moddable/blob/public/documentation/Moddable%20SDK%20-%20Getting%20Started.md#host-linux for more info.\n";\
	else\
		DEBUG=$(DEBUG) INSTRUMENT=$(INSTRUMENT) $(MAKE) -C $(MODDABLE)/build/devices/openwrt/targets -f make.libxs.mk clean;\
    fi
endef

define Build/Compile
	@if [ "$(MODDABLE)" = "" ]; then\
        echo -e "\n# Error: MODDABLE environment variable not set!\n# Visit https://github.com/Moddable-OpenSource/moddable/blob/public/documentation/Moddable%20SDK%20-%20Getting%20Started.md#host-linux for more info.\n";\
    else\
		$(MAKE) -C $(MODDABLE)/build/devices/openwrt/targets -f make.libxs.mk \
			CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
			DEBUG=$(DEBUG) INSTRUMENT=$(INSTRUMENT) PKG_BUILD_DIR=$(PKG_BUILD_DIR);\
	fi
endef

define Package/libxs/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libxs.so $(1)/usr/lib
endef

$(eval $(call BuildPackage,libxs))

