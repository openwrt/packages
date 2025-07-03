include $(TOPDIR)/rules.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-package.mk

PKG_NAME:=autojump
PKG_SOURCE_DATE:=20250227
PKG_SOURCE_VERSION:=ee21082751da739c65fe0ec2d02ca95d4266aebc
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/wting/autojump.git
PKG_MIRROR_HASH:=0153f9681ef3c30039cbec9c3853c1e9c35c7a7749b454f3bfc58494c70f5aaa

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python3/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/autojump
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=A shell extension to jump to frequently used directories
  URL:=https://github.com/wting/autojump
  DEPENDS:=+python3-codecs
endef

define Package/autojump/description
Autojump provides a more efficient way to navigate the filesystem, with a "cd command that learns."
It works by maintaining a database of directories and allows users to "jump" to frequently used
directories by typing only a small pattern. Supported shells include: bash, zsh, fish, and clink.
endef

define Build/Compile
	cd $(PKG_BUILD_DIR) && \
		SHELL=/bin/bash python3 install.py --prefix 'usr/' --destdir "$(PKG_INSTALL_DIR)" --zshshare 'usr/share/zsh/site-functions'
	mkdir -p "$(PKG_INSTALL_DIR)/usr/lib/python$(PYTHON3_VERSION)/site-packages"; \
	mv "$(PKG_INSTALL_DIR)/usr/bin/"*.py "$(PKG_INSTALL_DIR)/usr/lib/python$(PYTHON3_VERSION)/site-packages/"; \
	SHELL=/bin/bash python3 -m compileall -d /usr/lib "$(PKG_INSTALL_DIR)/usr/lib"; \
	SHELL=/bin/bash python3 -O -m compileall -d /usr/lib "$(PKG_INSTALL_DIR)/usr/lib";
endef

define Package/autojump/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/profile.d
	$(INSTALL_DIR) $(1)/usr/share/autojump
	$(INSTALL_DIR) $(1)/usr/share/fish/completions
	$(INSTALL_DIR) $(1)/usr/share/zsh/site-functions
	$(INSTALL_DIR) $(1)/usr/lib/python$(PYTHON3_VERSION)/site-packages
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/autojump $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/python$(PYTHON3_VERSION)/site-packages/__pycache__ $(1)/usr/lib/python$(PYTHON3_VERSION)/site-packages
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/python$(PYTHON3_VERSION)/site-packages/*.py $(1)/usr/lib/python$(PYTHON3_VERSION)/site-packages
	rm -f $(1)/etc/profile.d/autojump.*
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/profile.d/autojump.sh $(1)/etc/profile.d/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/autojump/autojump.bash $(1)/usr/share/autojump/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/autojump/autojump.fish $(1)/usr/share/fish/completions/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/autojump/autojump.zsh $(1)/usr/share/autojump/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/zsh/site-functions/_j $(1)/usr/share/zsh/site-functions/
	$(SED) s'|/local||' -i -e '27,31d' $(1)/etc/profile.d/autojump.sh
endef

$(eval $(call BuildPackage,autojump))
