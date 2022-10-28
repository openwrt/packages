#
# Copyright (C) 2022 Jianhui Zhao <zhaojh329@gmail.com>
#
# This is free software, licensed under the MIT.
#

define findrev
  $(shell \
    if git log -1 >/dev/null 2>/dev/null; then \
      set -- $$(git log -1 --format="%ct %h" --abbrev=7 -- .); \
      if [ -n "$$1" ]; then
        secs="$$(($$1 % 86400))"; \
        yday="$$(date --utc --date="@$$1" "+%Y.%j")"; \
        printf 'git-%s.%05d-%s' "$$yday" "$$secs" "$$2"; \
      else \
        echo "unknown"; \
      fi; \
    else \
      ts=$$(find . -type f -printf '%T@\n' 2>/dev/null | sort -rn | head -n1 | cut -d. -f1); \
      if [ -n "$$ts" ]; then \
        secs="$$(($$ts % 86400))"; \
        date="$$(date --utc --date="@$$ts" "+%Y%m%d")"; \
        printf '%s.%05d' "$$date" "$$secs"; \
      else \
        echo "unknown"; \
      fi; \
    fi \
  )
endef
