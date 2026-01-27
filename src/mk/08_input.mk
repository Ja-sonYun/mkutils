#
# Input
#

# Python UI script (base64 encoded)
_UTILS_PY_B64 := __UTILS_PY_B64__

# $(shell $(call select,options,prompt,default))
# --------------------------------
# Example:
#   $(shell $(call select,dev|staging|prod,Select environment,dev))
define select
python3 -c "$$(printf '%s' '$(_UTILS_PY_B64)' | $(_B64_DEC))" select '$(1)' '$(2)' '$(3)'
endef

# $(shell $(call select-multi,options,prompt,defaults))
# --------------------------------
# Example:
#   $(shell $(call select-multi,base|dev|prod,Select sources,base|dev))
define select-multi
python3 -c "$$(printf '%s' '$(_UTILS_PY_B64)' | $(_B64_DEC))" select-multi '$(1)' '$(2)' '$(3)'
endef

# $(shell $(call input,prompt,default))
# --------------------------------
# Example:
#   $(shell $(call input,Enter version,1.0.0))
define input
python3 -c "$$(printf '%s' '$(_UTILS_PY_B64)' | $(_B64_DEC))" input '$(1)' '$(2)'
endef

# $(call require-input,value,hint)
# --------------------------------
# Example:
#   $(call require-input,$(ENV),Selection cancelled)
define require-input
	@if [ -z "$(1)" ]; then \
		printf '$(RED)[ERROR]$(RESET) %s\n' "$(2)"; \
		exit 1; \
	fi
endef
