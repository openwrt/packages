#
# Copyright (C) 2014,2018 Hyperboria.net
#
# You may redistribute this program and/or modify it under the terms of
# the GNU General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-cjdns
PKG_VERSION:=1.3
PKG_RELEASE:=6

PKG_LICENSE:=GPL-3.0

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-cjdns
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=Encrypted near-zero-conf mesh routing protocol
	URL:=https://github.com/cjdelisle/cjdns
	MAINTAINER:=Lars Gierth <larsg@systemli.org>
	DEPENDS:=+cjdns +luci-base
endef

define Package/luci-app-cjdns/description
	This package allows you to configure and inspect cjdns networking using LuCI.

	Cjdns implements an encrypted IPv6 network using public-key cryptography
	for address allocation and a distributed hash table for routing.
	This provides near-zero-configuration networking, and prevents many
	of the security and scalability issues that plague existing networks.
endef

define Build/Compile
endef

define Package/luci-app-cjdns/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(CP) ./luasrc/* $(1)/usr/lib/lua/luci
endef

$(eval $(call BuildPackage,luci-app-cjdns))
