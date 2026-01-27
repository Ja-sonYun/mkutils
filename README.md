# mkutils

Makefile utilities

## Requirements

| Tool      | Version | Notes                                              |
| --------- | ------- | -------------------------------------------------- |
| GNU Make  | 3.81+   | `$(lastword)`, `$(eval)`, `define`                 |
| Bash      | 3.2+    | `read -r`, `pipefail`, `trap`                      |
| awk       | POSIX   | gawk, mawk, nawk, BSD awk supported                |
| coreutils | -       | `printf`, `tr`, `test`, `grep`, `cut`, `seq`, `bc` |
| ncurses   | -       | `tput` (terminal width)                            |
| python3   | 3.6+    | interactive input (select, select-multi, input)    |

**Optional:**

- `sha256sum` or `shasum` (deps functions)
- `lsof` (require-ports)
- `nc` (wait-for-port)
- `curl` (wait-for-url)

## Installation

```makefile
include dist/utils.mk
```

Copy `dist/utils.mk` to your project, or add this repository as a git submodule and include the file from there.

## Usage

### Help

```makefile
HELP_PROJECT_NAME := My Project
HELP_VERSION := 1.0.0

##@ Build
build: ## Build the project
	...
```

**Config:** `HELP_PROJECT_NAME` `HELP_VERSION` `HELP_VERSION_FILE` `HELP_WIDTH` `HELP_DESCRIPTION` `HELP_EXAMPLES` `HELP_VARIABLES`

### Args

```makefile
run: ## Run with arguments
	./app $(RUN_ARGS)
```

```bash
make run -- --verbose --config=prod
```

**Variables:** `$(RUN_ARGS)` `$(FIRST_ARG)`

### OS Detection

```makefile
build:
	@echo "OS: $(OS_NAME)"
ifeq ($(IS_MACOS),Darwin)
	@echo "macOS specific"
endif
ifeq ($(IS_LINUX),Linux)
	@echo "Linux specific"
endif
```

**Variables:** `$(OS_NAME)` `$(IS_MACOS)` `$(IS_LINUX)`

### Utilities

```makefile
# Cross-platform file replacement (handles macOS/Linux sed -i difference)
$(call replace,old,new,file.txt)

# Semver version bump
NEW := $(call semver-bump,patch,1.2.3)  # 1.2.4
NEW := $(call semver-bump,minor,1.2.3)  # 1.3.0
NEW := $(call semver-bump,major,1.2.3)  # 2.0.0
```

**Functions:** `replace` `semver-bump`

### String Escape

Escape special characters for safe shell usage:

```makefile
# Single option
$(call escape,dq,$(CMD))

# Combined options
$(call escape,dq|backtick,$(CMD))
```

| Option      | Escapes            |
| ----------- | ------------------ |
| `backslash` | `\` → `\\`         |
| `dq`        | `"` → `\"`         |
| `sq`        | `'` → `'\''`       |
| `backtick`  | `` ` `` → `` \` `` |

**Note:** Input should come from variables (env vars, shell output), not literal strings.

**Functions:** `escape`

### String

```makefile
# URL-safe slug
$(call slugify,Hello World! 123)   # hello-world-123

# Truncate string
$(call truncate,Hello World,5)     # Hello

# Left/right padding
$(call pad-left,42,5,0)            # 00042
$(call pad-right,42,5,0)           # 42000
```

**Functions:** `slugify` `truncate` `pad-left` `pad-right`

### Messages

```makefile
build:
	$(call msg-info,"Building...")
	$(call msg-success,"Done")
	$(call msg-warn,"Warning")
	$(call msg-error,"Error")
	$(call msg-step,1,3,"Step 1")
	$(call msg-header,"Title")
	$(call msg-sep)
	$(call msg-cmd,"npm install")      # display only
	$(call run-cmd,"npm install")      # display and run
	$(call confirm-run,rm -rf dist)                # confirm before run
	$(call confirm-run,rm -rf dist,Delete dist?)   # custom message
	$(call msg-status,PASS,"Test passed")
	$(call timed,npm run build)        # measure execution time
```

**Functions:** `msg-info` `msg-success` `msg-warn` `msg-error` `msg-step` `msg-header` `msg-sep` `msg-cmd` `run-cmd` `confirm-run` `msg-status` `timed`

**Variables:** `$(BLACK)` `$(RED)` `$(GREEN)` `$(YELLOW)` `$(BLUE)` `$(PURPLE)` `$(CYAN)` `$(WHITE)` `$(RESET)` `$(BOLD)` `$(DIM)`

Respects `NO_COLOR` environment variable.

### Validation

```makefile
build:
	$(call require-path,out/base|config.json,Required files missing)
	$(call require-cmd,docker|node|npm,Install required tools)
	$(call require-env,API_KEY|AWS_REGION,Set required env vars)
	$(call require-ports,3000|5432,Port already in use)
	$(call require-memory,4096,At least 4GB free memory required)
	$(call require-storage,10240,At least 10GB free disk space required)

deploy:
	$(call require-args,dev|prod|staging,Use: dev prod staging)
	$(call confirm,Deploy to $(FIRST_ARG)?)
	@echo "Deploying to $(FIRST_ARG)..."

release:
	$(call require-regex,$(VERSION),^[0-9]+\.[0-9]+\.[0-9]+$$,Version must be X.Y.Z)
	$(call require-version,node,18.0.0,Node 18+ required)

fetch:
	$(call retry,3,2,curl -f https://api.example.com/health)

start:
	docker-compose up -d
	$(call wait-for-port,localhost,5432,30)
	$(call wait-for-url,http://localhost:3000/health,30)
```

Use `|` as separator for multiple values.

**Functions:** `require-path` `require-cmd` `require-env` `require-args` `require-ports` `require-memory` `require-storage` `confirm` `require-regex` `require-version` `retry` `wait-for-port` `wait-for-url`

### Interactive Input

```makefile
deploy:
	# Single select (first option is default if not specified)
	$(eval ENV := $(shell $(call select,dev|staging|prod,Select environment,dev)))

	# Multi select
	$(eval SOURCES := $(shell $(call select-multi,base|dev|prod,Select sources,base|dev)))

	# Text input
	$(eval NAME := $(shell $(call input,Enter name,Anonymous)))

	# Validate input (exit if cancelled or empty)
	$(call require-input,$(ENV),Selection cancelled)
```

**Functions:** `select` `select-multi` `input` `require-input`

### Dependencies

```makefile
# Basic usage
$(eval $(call deps-target,node-deps,npm ci,package.json,package-lock.json,node_modules))
$(eval $(call deps-target-hash,py-deps,pip install -r requirements.txt,requirements.txt,requirements.lock,.venv))

# With folder argument (runs in specified directory)
$(eval $(call deps-target,frontend-deps,npm ci,package.json,package-lock.json,node_modules,frontend))
$(eval $(call deps-target-hash,backend-deps,pip install -r requirements.txt,requirements.txt,requirements.lock,.venv,backend))
```

| Macro              | Change Detection           | Use Case                                |
| ------------------ | -------------------------- | --------------------------------------- |
| `deps-target`      | File timestamp             | Simple projects, fast checks            |
| `deps-target-hash` | File content hash (SHA256) | Accurate detection after git operations |

**Generated targets:** `<name>` `<name>-force` `<name>-clean` (`deps-target-hash` also generates `<name>-check`)

### Dependency Presets

Shorthand macros for common package managers:

```makefile
# Node.js
$(eval $(call deps-npm,frontend))              # npm ci
$(eval $(call deps-pnpm,frontend))             # pnpm install --frozen-lockfile
$(eval $(call deps-yarn,frontend))             # yarn install --frozen-lockfile
$(eval $(call deps-bun,frontend))              # bun install --frozen-lockfile

# Python
$(eval $(call deps-poetry,backend))            # poetry install
$(eval $(call deps-uv,backend))                # uv sync
$(eval $(call deps-pip,backend))               # pip install -r requirements.txt

# With folder argument
$(eval $(call deps-npm,frontend-deps,frontend))
$(eval $(call deps-uv,backend-deps,backend))
```

| Preset        | Command                           | Lock File         | Output       |
| ------------- | --------------------------------- | ----------------- | ------------ |
| `deps-npm`    | `npm ci`                          | package-lock.json | node_modules |
| `deps-pnpm`   | `pnpm install --frozen-lockfile`  | pnpm-lock.yaml    | node_modules |
| `deps-yarn`   | `yarn install --frozen-lockfile`  | yarn.lock         | node_modules |
| `deps-bun`    | `bun install --frozen-lockfile`   | bun.lock          | node_modules |
| `deps-poetry` | `poetry install`                  | poetry.lock       | .venv        |
| `deps-uv`     | `uv sync`                         | uv.lock           | .venv        |
| `deps-pip`    | `pip install -r requirements.txt` | requirements.txt  | .venv        |

All presets use `deps-target-hash` (content hash detection) internally.

## Examples

### Conditional Builds

```makefile
build:
	$(eval SOURCE := $(shell $(call select,base|dev,Select source)))
	# Run only for 'base' builds
	$(if $(filter base,$(SOURCE)), \
		$(eval VARS_FILE := -var-file=base.pkrvars.hcl), \
	)
	# Require base image for non-base builds
	$(if $(filter-out base,$(SOURCE)), \
		$(call require-path,out/base,Run 'make build -- base' first), \
	)
	@echo "Building $(SOURCE)..."
```
