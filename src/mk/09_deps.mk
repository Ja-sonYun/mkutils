#
# Deps
#

_HASH_CMD := $(shell command -v sha256sum >/dev/null 2>&1 && echo 'sha256sum' || echo 'shasum -a 256')

# $(eval $(call deps-target,name,cmd,pkg,lock,outdir[,folder]))
# --------------------------------
# Example:
#   $(eval $(call deps-target,node-deps,npm ci,package.json,package-lock.json,node_modules))
#   $(eval $(call deps-target,frontend-deps,npm ci,package.json,package-lock.json,node_modules,frontend))
define deps-target
$(eval _dt_pkg   := $(if $(6),$(6)/$(3),$(3)))
$(eval _dt_lock  := $(if $(6),$(6)/$(4),$(4)))
$(eval _dt_out   := $(if $(6),$(6)/$(5),$(5)))
$(eval _dt_cmd   := $(if $(6),cd $(6) && $(2),$(2)))

.PHONY: $(1)
$(1): $(_dt_pkg) $(_dt_lock)
	@printf '$(BLUE)[DEPS]$(RESET) Installing dependencies for $(YELLOW)$(1)$(RESET)...\n'
	@if [ ! -d "$(_dt_out)" ] || [ "$(_dt_pkg)" -nt "$(_dt_out)/.installed" ] || [ "$(_dt_lock)" -nt "$(_dt_out)/.installed" ]; then \
		$(_dt_cmd); \
		mkdir -p $(_dt_out); \
		touch $(_dt_out)/.installed; \
		printf '$(GREEN)[OK]$(RESET) Dependencies installed for $(YELLOW)$(1)$(RESET)\n'; \
	else \
		printf '$(GREEN)[OK]$(RESET) Dependencies for $(YELLOW)$(1)$(RESET) are up to date\n'; \
	fi

.PHONY: $(1)-force
$(1)-force:
	@printf '$(YELLOW)[FORCE]$(RESET) Force installing dependencies for $(YELLOW)$(1)$(RESET)...\n'
	$(_dt_cmd)
	@mkdir -p $(_dt_out)
	@touch $(_dt_out)/.installed

.PHONY: $(1)-clean
$(1)-clean:
	@printf '$(RED)[CLEAN]$(RESET) Cleaning $(YELLOW)$(1)$(RESET) dependencies...\n'
	rm -rf $(_dt_out)
endef

# $(eval $(call deps-target-hash,name,cmd,pkg,lock,outdir[,folder]))
# --------------------------------
# Example:
#   $(eval $(call deps-target-hash,py-deps,pip install -r requirements.txt,requirements.txt,requirements.lock,.venv))
#   $(eval $(call deps-target-hash,backend-deps,pip install -r requirements.txt,requirements.txt,requirements.lock,.venv,backend))
define deps-target-hash
$(eval _dth_pkg  := $(if $(6),$(6)/$(3),$(3)))
$(eval _dth_lock := $(if $(6),$(6)/$(4),$(4)))
$(eval _dth_out  := $(if $(6),$(6)/$(5),$(5)))
$(eval _dth_cmd  := $(if $(6),cd $(6) && $(2),$(2)))

$(_dth_out)/.deps-hash: $(_dth_pkg) $(_dth_lock)
	@printf '$(BLUE)[DEPS]$(RESET) Installing dependencies for $(YELLOW)$(1)$(RESET)...\n'
	$(_dth_cmd)
	@mkdir -p $(_dth_out)
	@cat $(_dth_pkg) $(_dth_lock) 2>/dev/null | $(_HASH_CMD) | cut -d' ' -f1 > $$@
	@printf '$(GREEN)[OK]$(RESET) Dependencies installed for $(YELLOW)$(1)$(RESET)\n'

.PHONY: $(1)
$(1): $(_dth_out)/.deps-hash

.PHONY: $(1)-check
$(1)-check:
	@if [ -f "$(_dth_out)/.deps-hash" ] && \
	   [ "$$$$(cat $(_dth_pkg) $(_dth_lock) 2>/dev/null | $(_HASH_CMD) | cut -d' ' -f1)" = "$$$$(cat $(_dth_out)/.deps-hash 2>/dev/null)" ]; then \
		printf '$(GREEN)[OK]$(RESET) Dependencies for $(YELLOW)$(1)$(RESET) are up to date\n'; \
	else \
		printf '$(YELLOW)[WARN]$(RESET) Dependencies for $(YELLOW)$(1)$(RESET) need updating\n'; \
	fi

.PHONY: $(1)-force
$(1)-force:
	@printf '$(YELLOW)[FORCE]$(RESET) Force installing dependencies for $(YELLOW)$(1)$(RESET)...\n'
	$(_dth_cmd)
	@mkdir -p $(_dth_out)
	@cat $(_dth_pkg) $(_dth_lock) 2>/dev/null | $(_HASH_CMD) | cut -d' ' -f1 > $(_dth_out)/.deps-hash

.PHONY: $(1)-clean
$(1)-clean:
	@printf '$(RED)[CLEAN]$(RESET) Cleaning $(YELLOW)$(1)$(RESET) dependencies...\n'
	rm -rf $(_dth_out)
endef

#
# Deps Presets
#

# $(eval $(call deps-npm,name[,folder]))
# --------------------------------
# Example:
#   $(eval $(call deps-npm,node-deps))
#   $(eval $(call deps-npm,frontend-deps,frontend))
define deps-npm
$(eval $(call deps-target-hash,$(1),npm ci,package.json,package-lock.json,node_modules,$(2)))
endef

# $(eval $(call deps-pnpm,name[,folder]))
# --------------------------------
# Example:
#   $(eval $(call deps-pnpm,node-deps))
#   $(eval $(call deps-pnpm,frontend-deps,frontend))
define deps-pnpm
$(eval $(call deps-target-hash,$(1),pnpm install --frozen-lockfile,package.json,pnpm-lock.yaml,node_modules,$(2)))
endef

# $(eval $(call deps-yarn,name[,folder]))
# --------------------------------
# Example:
#   $(eval $(call deps-yarn,node-deps))
#   $(eval $(call deps-yarn,frontend-deps,frontend))
define deps-yarn
$(eval $(call deps-target-hash,$(1),yarn install --frozen-lockfile,package.json,yarn.lock,node_modules,$(2)))
endef

# $(eval $(call deps-bun,name[,folder]))
# --------------------------------
# Example:
#   $(eval $(call deps-bun,node-deps))
#   $(eval $(call deps-bun,frontend-deps,frontend))
define deps-bun
$(eval $(call deps-target-hash,$(1),bun install --frozen-lockfile,package.json,bun.lock,node_modules,$(2)))
endef

# $(eval $(call deps-poetry,name[,folder]))
# --------------------------------
# Example:
#   $(eval $(call deps-poetry,py-deps))
#   $(eval $(call deps-poetry,backend-deps,backend))
define deps-poetry
$(eval $(call deps-target-hash,$(1),poetry install,pyproject.toml,poetry.lock,.venv,$(2)))
endef

# $(eval $(call deps-uv,name[,folder]))
# --------------------------------
# Example:
#   $(eval $(call deps-uv,py-deps))
#   $(eval $(call deps-uv,backend-deps,backend))
define deps-uv
$(eval $(call deps-target-hash,$(1),uv sync,pyproject.toml,uv.lock,.venv,$(2)))
endef

# $(eval $(call deps-pip,name[,folder]))
# --------------------------------
# Example:
#   $(eval $(call deps-pip,py-deps))
#   $(eval $(call deps-pip,backend-deps,backend))
define deps-pip
$(eval $(call deps-target-hash,$(1),pip install -r requirements.txt,requirements.txt,requirements.txt,.venv,$(2)))
endef
