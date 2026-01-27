#
# String
#

# $(call slugify,string)
# --------------------------------
# Example:
#   $(call slugify,Hello World! 123) -> hello-world-123
slugify = $(shell echo '$(1)' | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' '-' | sed 's/^-//;s/-$$//')

# $(call truncate,string,length)
# --------------------------------
# Example:
#   $(call truncate,Hello World,5) -> Hello
truncate = $(shell echo '$(1)' | cut -c1-$(2))

# $(call pad-left,string,length,char)
# --------------------------------
# Example:
#   $(call pad-left,42,5,0) -> 00042
pad-left = $(shell printf '%*s' $(2) '$(1)' | tr ' ' '$(3)')

# $(call pad-right,string,length,char)
# --------------------------------
# Example:
#   $(call pad-right,42,5,0) -> 42000
pad-right = $(shell printf '%-*s' $(2) '$(1)' | tr ' ' '$(3)')
