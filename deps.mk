# deps.mk - Generic dependency management module

# Colors
ifeq ($(NO_COLOR),)
  DEPS_COLOR_RESET   := \033[0m
  DEPS_COLOR_GREEN   := \033[0;32m
  DEPS_COLOR_YELLOW  := \033[0;33m
  DEPS_COLOR_BLUE    := \033[0;34m
  DEPS_COLOR_RED     := \033[0;31m
else
  DEPS_COLOR_RESET   :=
  DEPS_COLOR_GREEN   :=
  DEPS_COLOR_YELLOW  :=
  DEPS_COLOR_BLUE    :=
  DEPS_COLOR_RED     :=
endif

# Function to create dependency install target
# Usage: $(call create-deps-target,target-name,command,package-file,lock-file,output-dir,description)
define create-deps-target
.PHONY: $(1)
$(1): $(3) $(4) ## $(6)
	@printf '$(DEPS_COLOR_BLUE)[DEPS]$(DEPS_COLOR_RESET) Installing dependencies for $(DEPS_COLOR_YELLOW)$(1)$(DEPS_COLOR_RESET)...\n'
	@if [ ! -d "$(5)" ] || [ "$(3)" -nt "$(5)/.installed" ] || [ "$(4)" -nt "$(5)/.installed" ]; then \
		$(2); \
		mkdir -p $(5); \
		touch $(5)/.installed; \
		printf '$(DEPS_COLOR_GREEN)[OK]$(DEPS_COLOR_RESET) Dependencies installed for $(DEPS_COLOR_YELLOW)$(1)$(DEPS_COLOR_RESET)\n'; \
	else \
		printf '$(DEPS_COLOR_GREEN)[OK]$(DEPS_COLOR_RESET) Dependencies for $(DEPS_COLOR_YELLOW)$(1)$(DEPS_COLOR_RESET) are up to date\n'; \
	fi

.PHONY: $(1)-force
$(1)-force: ## Force install $(6)
	@printf '$(DEPS_COLOR_YELLOW)[FORCE]$(DEPS_COLOR_RESET) Force installing dependencies for $(DEPS_COLOR_YELLOW)$(1)$(DEPS_COLOR_RESET)...\n'
	$(2)
	@mkdir -p $(5)
	@touch $(5)/.installed

.PHONY: $(1)-clean
$(1)-clean: ## Clean $(6)
	@printf '$(DEPS_COLOR_RED)[CLEAN]$(DEPS_COLOR_RESET) Cleaning $(DEPS_COLOR_YELLOW)$(1)$(DEPS_COLOR_RESET) dependencies...\n'
	rm -rf $(5)
endef

# Function with hash checking
# Usage: $(call create-deps-target-with-hash,target-name,command,package-file,lock-file,output-dir,description)
define create-deps-target-with-hash
$(5)/.deps-hash: $(3) $(4)
	@printf '$(DEPS_COLOR_BLUE)[DEPS]$(DEPS_COLOR_RESET) Installing dependencies for $(DEPS_COLOR_YELLOW)$(1)$(DEPS_COLOR_RESET)...\n'
	$(2)
	@mkdir -p $(5)
	@cat $(3) $(4) 2>/dev/null | shasum -a 256 | cut -d' ' -f1 > $$@
	@printf '$(DEPS_COLOR_GREEN)[OK]$(DEPS_COLOR_RESET) Dependencies installed for $(DEPS_COLOR_YELLOW)$(1)$(DEPS_COLOR_RESET)\n'

.PHONY: $(1)
$(1): $(5)/.deps-hash ## $(6)

.PHONY: $(1)-check
$(1)-check: ## Check if $(6) need updating
	@if [ -f "$(5)/.deps-hash" ] && [ "$$$$(cat $(3) $(4) 2>/dev/null | shasum -a 256 | cut -d' ' -f1)" = "$$$$(cat $(5)/.deps-hash 2>/dev/null)" ]; then \
		printf '$(DEPS_COLOR_GREEN)[OK]$(DEPS_COLOR_RESET) Dependencies for $(DEPS_COLOR_YELLOW)$(1)$(DEPS_COLOR_RESET) are up to date\n'; \
	else \
		printf '$(DEPS_COLOR_YELLOW)[WARN]$(DEPS_COLOR_RESET) Dependencies for $(DEPS_COLOR_YELLOW)$(1)$(DEPS_COLOR_RESET) need updating\n'; \
	fi

.PHONY: $(1)-force
$(1)-force: ## Force install $(6)
	@printf '$(DEPS_COLOR_YELLOW)[FORCE]$(DEPS_COLOR_RESET) Force installing dependencies for $(DEPS_COLOR_YELLOW)$(1)$(DEPS_COLOR_RESET)...\n'
	$(2)
	@mkdir -p $(5)
	@cat $(3) $(4) 2>/dev/null | shasum -a 256 | cut -d' ' -f1 > $(5)/.deps-hash

.PHONY: $(1)-clean
$(1)-clean: ## Clean $(6)
	@printf '$(DEPS_COLOR_RED)[CLEAN]$(DEPS_COLOR_RESET) Cleaning $(DEPS_COLOR_YELLOW)$(1)$(DEPS_COLOR_RESET) dependencies...\n'
	rm -rf $(5)
endef

.PHONY: all clean test
