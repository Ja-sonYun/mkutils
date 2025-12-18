# mkutils

Reusable Makefile modules.

## Installation

```makefile
include init.mk
$(call import,colors)
$(call import,help)
```

Modules are downloaded from GitHub and cached in `.mkutils/`.

## Modules

### init.mk

Bootstrap module providing `import` function.

### args.mk

Handle command line arguments after `--`.

```makefile
$(call import,args)

run: ## Run with arguments
	./app $(RUN_ARGS)
```

```bash
make run -- --verbose --config=prod
```

### colors.mk

Terminal colors respecting `NO_COLOR`.

```makefile
$(call import,colors)

build:
	$(call print_info,"Building...")
	$(call print_success,"Done")
	$(call print_warning,"Warning")
	$(call print_error,"Error")
	$(call print_step,1,3,"Step")
	$(call print_header,"Title")
```

**Colors:** `$(BLACK)` `$(RED)` `$(GREEN)` `$(YELLOW)` `$(BLUE)` `$(PURPLE)` `$(CYAN)` `$(WHITE)` `$(RESET)`

**Bold:** `$(BOLD)` `$(BOLD_RED)` `$(BOLD_GREEN)` `$(BOLD_YELLOW)` `$(BOLD_BLUE)` `$(BOLD_PURPLE)` `$(BOLD_CYAN)`

**Background:** `$(BG_RED)` `$(BG_GREEN)` `$(BG_YELLOW)` `$(BG_BLUE)` `$(BG_PURPLE)` `$(BG_CYAN)`

**Styles:** `$(DIM)` `$(UNDERLINE)` `$(BLINK)` `$(REVERSE)`

**Functions:** `print_info` `print_success` `print_warning` `print_error` `print_step` `print_header` `print_status`

### deps.mk

Dependency management with update detection.

```makefile
$(call import,deps)

# Basic: tracks file modification time
$(eval $(call create-deps-target,\
    deps,npm install,package.json,package-lock.json,node_modules,Node.js))

# With hash: tracks content changes via SHA256
$(eval $(call create-deps-target-with-hash,\
    py-deps,pip install -r requirements.txt,requirements.txt,requirements.lock,.venv,Python))
```

**Generated targets:**
- `make <name>` - Install if outdated
- `make <name>-force` - Force reinstall
- `make <name>-clean` - Remove dependencies
- `make <name>-check` - Check if update needed (hash version only)

### help.mk

Auto-generated help from `##` comments.

```makefile
$(call import,help)

HELP_PROJECT_NAME := My Project
HELP_VERSION := 1.0.0

##@ Build
build: ## Build the project
	...
```

**Config:** `HELP_PROJECT_NAME` `HELP_VERSION` `HELP_VERSION_FILE` `HELP_WIDTH` `HELP_DESCRIPTION` `HELP_DESCRIPTION_MD` `HELP_DESCRIPTION_SECTION` `HELP_EXAMPLES` `HELP_EXAMPLE_MD` `HELP_EXAMPLE_SECTION` `HELP_VARIABLES`

**Targets:** `help` (default) `version`

## License

MIT
