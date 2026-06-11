ifndef DUMP
  ifdef __package_mk
    $(warning metacpan.mk should be included before package.mk)
  endif
endif

ifneq ($(strip $(METACPAN_NAME)),)
  ifneq ($(strip $(METACPAN_AUTHOR)),)
    METACPAN_SOURCE_NAME?=$(METACPAN_NAME)
    METACPAN_SOURCE_EXT?=tar.gz
    METACPAN_AUTHOR_FIRST_LETTER?=$(strip $(foreach a,A B C D E F G H I J K L M N O P Q R S T U V W X Y Z,$(if $(METACPAN_AUTHOR:$a%=),,$a)))
    METACPAN_AUTHOR_SECOND_LETTER?=$(strip $(foreach a,A B C D E F G H I J K L M N O P Q R S T U V W X Y Z,$(if $(METACPAN_AUTHOR:$(METACPAN_AUTHOR_FIRST_LETTER)$a%=),,$a)))

    PKG_SOURCE:=$(METACPAN_SOURCE_NAME)-$(PKG_VERSION).$(METACPAN_SOURCE_EXT)
    PKG_SOURCE_URL:=https://cpan.metacpan.org/authors/id/$(METACPAN_AUTHOR_FIRST_LETTER)/$(METACPAN_AUTHOR_FIRST_LETTER)$(METACPAN_AUTHOR_SECOND_LETTER)/$(METACPAN_AUTHOR)

    PKG_BUILD_DIR:=$(BUILD_DIR)/perl/$(if $(BUILD_VARIANT),$(PKG_NAME)-$(BUILD_VARIANT)/)$(METACPAN_SOURCE_NAME)$(if $(PKG_VERSION),-$(PKG_VERSION))
    HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/perl/$(METACPAN_SOURCE_NAME)$(if $(PKG_VERSION),-$(PKG_VERSION))
  endif
endif

