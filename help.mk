# help.mk - Modular help system for Makefile

# Default configuration
HELP_PROJECT_NAME ?= Project
HELP_VERSION_FILE ?=
HELP_VERSION ?=
HELP_WIDTH ?= 20
HELP_EXAMPLE_MD ?=
HELP_EXAMPLE_SECTION ?= Examples
HELP_DESCRIPTION_MD ?=
HELP_DESCRIPTION_SECTION ?= Description

# Extract version from file if HELP_VERSION_FILE is set
ifdef HELP_VERSION_FILE
  ifneq ($(wildcard $(HELP_VERSION_FILE)),)
    # Try different version patterns
    EXTRACTED_VERSION := $(shell grep -E '(version|Version|VERSION)' $(HELP_VERSION_FILE) | head -1 | sed 's/[":,=]//g' | tr '[:upper:]' '[:lower:]' | awk '{print $$2}')
    HELP_VERSION := $(EXTRACTED_VERSION)
  endif
endif

# Colors
ifeq ($(NO_COLOR),)
  HELP_COLOR_RESET   := \033[0m
  HELP_COLOR_BOLD    := \033[1m
  HELP_COLOR_RED     := \033[0;31m
  HELP_COLOR_GREEN   := \033[0;32m
  HELP_COLOR_YELLOW  := \033[0;33m
  HELP_COLOR_BLUE    := \033[0;34m
  HELP_COLOR_CYAN    := \033[0;36m
  HELP_COLOR_DIM     := \033[2m
else
  HELP_COLOR_RESET   :=
  HELP_COLOR_BOLD    :=
  HELP_COLOR_RED     :=
  HELP_COLOR_GREEN   :=
  HELP_COLOR_YELLOW  :=
  HELP_COLOR_BLUE    :=
  HELP_COLOR_CYAN    :=
  HELP_COLOR_DIM     :=
endif

##@ Help
.PHONY: help
help: ## Show this help message
	@printf '$(HELP_COLOR_BOLD)$(HELP_COLOR_BLUE)%s$(HELP_COLOR_RESET)' "$(HELP_PROJECT_NAME)"
	@if [ -n "$(HELP_VERSION)" ]; then printf ' $(HELP_COLOR_DIM)v$(HELP_VERSION)$(HELP_COLOR_RESET)'; fi
	@printf '\n'
	@# Show description with indentation - preserve newlines and code blocks
ifdef HELP_DESCRIPTION_MD
	@if [ -f "$(HELP_DESCRIPTION_MD)" ]; then \
		printf '$(HELP_COLOR_DIM)'; \
		awk 'BEGIN{code=0} /^#+ $(HELP_DESCRIPTION_SECTION)/{flag=1;next} /^```/{code=!code} /^#+ / && !code{flag=0} flag&&NF{print "  " $$0} flag&&!NF{print ""}' $(HELP_DESCRIPTION_MD); \
		printf '$(HELP_COLOR_RESET)'; \
	fi
else ifdef HELP_DESCRIPTION
	@printf '$(HELP_COLOR_DIM)'
	@echo "$$HELP_DESCRIPTION" | while IFS= read -r line; do printf '  %s\n' "$$line"; done
	@printf '$(HELP_COLOR_RESET)'
else
	@printf '\n'
endif
	@printf '$(HELP_COLOR_YELLOW)Usage:$(HELP_COLOR_RESET) make [target] [VARIABLE=value]\n\n'
ifdef HELP_EXAMPLE_MD
	@if [ -f "$(HELP_EXAMPLE_MD)" ]; then \
		if awk '/^#+ $(HELP_EXAMPLE_SECTION)/{flag=1;next}/^#/{flag=0}flag' $(HELP_EXAMPLE_MD) | grep -q .; then \
			printf '$(HELP_COLOR_YELLOW)Examples:$(HELP_COLOR_RESET)\n'; \
			printf '$(HELP_COLOR_DIM)'; \
			awk 'BEGIN{code=0} /^#+ $(HELP_EXAMPLE_SECTION)/{flag=1;next} /^```/{code=!code} /^#+ / && !code{flag=0} flag{print "  " $$0}' $(HELP_EXAMPLE_MD); \
			printf '$(HELP_COLOR_RESET)'; \
		fi \
	fi
else ifdef HELP_EXAMPLES
	@printf '$(HELP_COLOR_YELLOW)Examples:$(HELP_COLOR_RESET)\n'
	@printf '$(HELP_COLOR_DIM)'
	@echo "$$HELP_EXAMPLES" | while IFS= read -r line; do printf '  %s\n' "$$line"; done
	@printf '$(HELP_COLOR_RESET)\n'
endif
ifdef HELP_VARIABLES
	@printf '$(HELP_COLOR_YELLOW)Variables:$(HELP_COLOR_RESET)\n'
	@printf '$(HELP_COLOR_DIM)'
	@echo "$$HELP_VARIABLES" | while IFS= read -r line; do printf '  %s\n' "$$line"; done
	@printf '$(HELP_COLOR_RESET)\n'
endif
	@printf '$(HELP_COLOR_YELLOW)Targets:$(HELP_COLOR_RESET)\n'
	@awk 'BEGIN {FS = ":.*?## "} \
		/^[a-zA-Z_-]+:.*?## / { \
			printf "    $(HELP_COLOR_GREEN)%-$(HELP_WIDTH)s$(HELP_COLOR_RESET) %s\n", $$1, $$2 \
		} \
		/^##@/ { \
			printf "\n  $(HELP_COLOR_CYAN)%s$(HELP_COLOR_RESET)\n", substr($$0, 5) \
		}' $(MAKEFILE_LIST)
	@printf '\n'

.PHONY: version
version: ## Show version information
	@printf '$(HELP_PROJECT_NAME) $(HELP_VERSION)\n'

.DEFAULT_GOAL := help

.PHONY: all clean test
