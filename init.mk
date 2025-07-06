$(shell [ -d .mkutils ] || mkdir -p .mkutils)

define import
include $(shell [ -f .mkutils/$(1).mk ] && find .mkutils/$(1).mk -mtime -1 >/dev/null 2>&1 || curl -s https://raw.githubusercontent.com/Ja-sonYun/mkutils/refs/heads/main/$(1).mk > .mkutils/$(1).mk; echo .mkutils/$(1).mk)
endef
