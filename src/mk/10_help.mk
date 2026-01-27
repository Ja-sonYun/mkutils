#
# Help
#

HELP_PROJECT_NAME ?= Project
HELP_VERSION_FILE ?=
HELP_VERSION      ?=
HELP_WIDTH        ?= 20

ifdef HELP_VERSION_FILE
	ifneq ($(wildcard $(HELP_VERSION_FILE)),)
		HELP_VERSION := $(shell awk -F'[":=, \t]+' '/[Vv]ersion/ { \
			for(i=1;i<=NF;i++) if($$i ~ /^[0-9]+\.[0-9]/) { print $$i; exit } \
		}' $(HELP_VERSION_FILE))
	endif
endif

# Help AWK script (base64 encoded)
_HELP_AWK_B64 := __HELP_AWK_B64__

##@ Help

.PHONY: help
help: ## Show this help message
	@printf '%s' '$(_HELP_AWK_B64)' | $(_B64_DEC) | awk -f - \
		-v project="$(HELP_PROJECT_NAME)" \
		-v version="$(HELP_VERSION)" \
		-v width="$(HELP_WIDTH)" \
		-v no_color="$(NO_COLOR)" \
		-v description="$${HELP_DESCRIPTION:-}" \
		-v examples="$${HELP_EXAMPLES:-}" \
		-v variables="$${HELP_VARIABLES:-}" \
		$(MAKEFILE_LIST)

.PHONY: version
version: ## Show version information
	@printf '%s %s\n' "$(HELP_PROJECT_NAME)" "$(HELP_VERSION)"

.DEFAULT_GOAL := help
