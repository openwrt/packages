include qt.mk

define DefineQt5Library
  define Package/qt5base-$(1)
    $(call Package/qt5/Default)
    TITLE:=Qt $(1) Library
    DEPENDS+=$(foreach lib,$(2),+qt5base-$(lib)) $(3)
    HIDDEN:=1
  endef

  define Package/qt5base-$(1)/description
    This package contains the Qt $(1) library.
  endef

  define Package/qt5base-$(1)/install
    $(call Build/Install/Libs,$$(1),$(1))
  endef
endef

define DefineQt5Plugin
  define Package/qt5base-plugin-$(1)
    $(call Package/qt5/Default)
    TITLE:=Qt $(5) Plugin
    DEPENDS+=$(foreach lib,$(2),+qt5base-$(lib)) $(3)
    HIDDEN:=1
  endef

  define Package/qt5base-plugin-$(1)/description
    This package contains the Qt $(5) Plugin.
  endef

  define Package/qt5base-plugin-$(1)/install
    $(call Build/Install/Plugins,$$(1),$(4))
  endef
endef
