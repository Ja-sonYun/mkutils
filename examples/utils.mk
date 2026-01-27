# Example usage of utils.mk
# Run: make -f examples/utils.mk

include dist/utils.mk

HELP_PROJECT_NAME := Example Project
HELP_VERSION := 1.0.0

##@ Messages
demo-messages: ## Show all message functions
	$(call msg-info,"This is an info message")
	$(call msg-success,"This is a success message")
	$(call msg-warn,"This is a warning message")
	$(call msg-error,"This is an error message")
	$(call msg-step,1,3,"Step 1 of 3")
	$(call msg-step,2,3,"Step 2 of 3")
	$(call msg-step,3,3,"Step 3 of 3")
	$(call msg-status,PASS,"Test passed")
	$(call msg-sep)
	$(call msg-cmd,"npm install")
	$(call msg-header,"Header Title")

##@ Validation
demo-validate: ## Show validation functions (will pass)
	$(call require-path,Makefile|examples,Required paths)
	$(call require-cmd,make|sh,Required commands)
	$(call require-env,HOME|USER,Required env vars)
	$(call msg-success,"All validations passed")

demo-resources: ## Check system resources (memory and storage)
	$(call require-memory,512,At least 512MB free memory required)
	$(call require-storage,1024,At least 1GB free disk space required)
	$(call msg-success,"System resources check passed")

demo-args: ## Validate arguments (run: make demo-args -- dev)
	$(call require-args,dev|prod|staging,Use: dev prod staging)
	$(call msg-success,"Deploying to $(FIRST_ARG)")

demo-confirm: ## Ask for confirmation
	$(call confirm,Continue with demo?)
	$(call msg-success,"Confirmed")

demo-confirm-run: ## Ask for confirmation to run command
	$(call confirm-run,echo "default message")
	$(call confirm-run,echo "custom message",Execute echo command?)
	$(call msg-success,"Commands executed")

demo-regex: ## Validate version format (run: make demo-regex VERSION=1.2.3)
	$(call require-regex,$(VERSION),^[0-9]+\.[0-9]+\.[0-9]+$$,Version must be X.Y.Z)
	$(call msg-success,"Version $(VERSION) is valid")

##@ Interactive
demo-select: ## Select from options
	$(eval ENV := $(shell $(call select,dev|staging|prod,Select environment,dev)))
	$(call require-input,$(ENV),Selection cancelled)
	$(call msg-success,"Selected: $(ENV)")

demo-input: ## Text input with default
	$(eval NAME := $(shell $(call input,Enter your name,Anonymous)))
	$(call require-input,$(NAME),Input cancelled)
	$(call msg-success,"Hello $(NAME)")

demo-select-multi: ## Multi-select from options
	$(eval SOURCES := $(shell $(call select-multi,base|dev|ctf|prod,Select sources,base|dev)))
	$(call require-input,$(SOURCES),Selection cancelled)
	$(call msg-success,"Selected: $(SOURCES)")

##@ System Info
demo-os: ## Show OS detection variables
	@echo "OS_NAME:  $(OS_NAME)"
	@echo "IS_MACOS: $(IS_MACOS)"
	@echo "IS_LINUX: $(IS_LINUX)"

##@ Utilities
demo-replace: ## Replace text in file
	@echo "old-value" > /tmp/test-replace.txt
	@echo "Before: $$(cat /tmp/test-replace.txt)"
	@$(call replace,old-value,new-value,/tmp/test-replace.txt)
	@echo "After:  $$(cat /tmp/test-replace.txt)"
	@rm -f /tmp/test-replace.txt

demo-semver: ## Bump semver version
	@echo "Current: 1.2.3"
	@echo "patch:   $(call semver-bump,patch,1.2.3)"
	@echo "minor:   $(call semver-bump,minor,1.2.3)"
	@echo "major:   $(call semver-bump,major,1.2.3)"

##@ Waiting
demo-wait-url: ## Wait for URL to respond
	$(call wait-for-url,https://httpbin.org/get,10)

##@ Execution
demo-timed: ## Measure command execution time
	$(call timed,sleep 1)

demo-retry: ## Retry on failure (random success)
	$(call retry,5,1,test $$(($$RANDOM % 3)) -eq 0)

demo-require-version: ## Check command version
	$(call require-version,make,3.81,GNU Make 3.81+ required)
	$(call require-version,python3,3.8,Python 3.8+ required)
	$(call msg-success,"Version check passed")

##@ Dependencies

# Basic deps-target (timestamp-based)
$(eval $(call deps-target,demo-deps,echo "Installing...",Makefile,Makefile,.demo-deps))

# deps-target-hash (content hash-based, more accurate)
$(eval $(call deps-target-hash,demo-deps-hash,echo "Installing...",Makefile,Makefile,.demo-deps-hash))

# Presets - uncomment to use:
# $(eval $(call deps-npm,node-deps))                    # npm ci
# $(eval $(call deps-npm,frontend-deps,frontend))      # npm ci in frontend/
# $(eval $(call deps-pnpm,node-deps))                  # pnpm install --frozen-lockfile
# $(eval $(call deps-yarn,node-deps))                  # yarn install --frozen-lockfile
# $(eval $(call deps-bun,node-deps))                   # bun install --frozen-lockfile
# $(eval $(call deps-poetry,py-deps))                  # poetry install
# $(eval $(call deps-uv,py-deps))                      # uv sync
# $(eval $(call deps-uv,backend-deps,backend))         # uv sync in backend/
# $(eval $(call deps-pip,py-deps))                     # pip install -r requirements.txt

.PHONY: demo-messages demo-validate demo-resources demo-args demo-confirm demo-regex demo-select demo-input demo-select-multi
.PHONY: demo-os demo-replace demo-semver demo-wait-url
.PHONY: demo-timed demo-retry demo-require-version
