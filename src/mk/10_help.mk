#
# Help
#

HELP_PROJECT_NAME ?= Project
HELP_VERSION_FILE ?=
HELP_VERSION      ?= $(if $(wildcard $(HELP_VERSION_FILE)),$(shell awk -F'[":=, \t]+' '/[Vv]ersion/ { \
	for(i=1;i<=NF;i++) if($$i ~ /^[0-9]+\.[0-9]/) { print $$i; exit } \
}' '$(subst ','"'"',$(HELP_VERSION_FILE))'))
HELP_WIDTH        ?= 20

# Help AWK script (base64 encoded)
_HELP_AWK_B64 := __HELP_AWK_B64__

##@ Help

.PHONY: help
help: export _help_description = $(HELP_DESCRIPTION)
help: export _help_examples = $(HELP_EXAMPLES)
help: export _help_variables = $(HELP_VARIABLES)
help: ## Show this help message
	@printf '%s' '$(_HELP_AWK_B64)' | $(_B64_DEC) | awk -f - \
		-v project="$(HELP_PROJECT_NAME)" \
		-v version="$(HELP_VERSION)" \
		-v width="$(HELP_WIDTH)" \
		-v no_color="$(NO_COLOR)" \
		-v description="$$_help_description" \
		-v examples="$$_help_examples" \
		-v variables="$$_help_variables" \
		$(MAKEFILE_LIST)

.PHONY: version
version: ## Show version information
	@printf '%s %s\n' "$(HELP_PROJECT_NAME)" "$(HELP_VERSION)"

ifeq ($(.DEFAULT_GOAL),)
.DEFAULT_GOAL := help
endif
