#
# Validation
#

# $(call require-path,paths,hint)
# --------------------------------
# Example:
#   $(call require-path,src/main.go|go.mod,Run: go mod init)
define require-path
	@set -eo pipefail; \
	printf '%s\n' '$(1)' | tr '|' '\n' | while IFS= read -r p; do \
		test -e "$$p" || { \
			printf '$(RED)[ERROR]$(RESET) Path not found: $(YELLOW)%s$(RESET)\n' "$$p"; \
			printf '$(DIM)        %s$(RESET)\n' "$(2)"; \
			exit 1; \
		}; \
	done
endef

# $(call require-cmd,commands,hint)
# --------------------------------
# Example:
#   $(call require-cmd,docker|kubectl,Install Docker and kubectl)
define require-cmd
	@set -eo pipefail; \
	printf '%s\n' '$(1)' | tr '|' '\n' | while IFS= read -r c; do \
		command -v "$$c" >/dev/null 2>&1 || { \
			printf '$(RED)[ERROR]$(RESET) Command not found: $(YELLOW)%s$(RESET)\n' "$$c"; \
			printf '$(DIM)        %s$(RESET)\n' "$(2)"; \
			exit 1; \
		}; \
	done
endef

# $(call require-env,vars,hint)
# --------------------------------
# Example:
#   $(call require-env,API_KEY|DB_HOST,Set required env vars)
define require-env
	@set -eo pipefail; \
	printf '%s\n' '$(1)' | tr '|' '\n' | while IFS= read -r v; do \
		eval "val=\$${$$v:-}"; \
		test -n "$$val" || { \
			printf '$(RED)[ERROR]$(RESET) Environment variable not set: $(YELLOW)%s$(RESET)\n' "$$v"; \
			printf '$(DIM)        %s$(RESET)\n' "$(2)"; \
			exit 1; \
		}; \
	done
endef

# $(call require-args,allowed,hint)
# --------------------------------
# Example:
#   $(call require-args,dev|staging|prod,Usage: make deploy <env>)
define require-args
	@allowed=$$(printf '%s\n' '$(1)' | tr '|' ' '); \
	if [ -z "$(FIRST_ARG)" ] || ! echo " $$allowed " | grep -q " $(FIRST_ARG) "; then \
		printf '$(RED)[ERROR]$(RESET) Invalid argument: $(YELLOW)%s$(RESET) (allowed: %s)\n' "$(FIRST_ARG)" "$$allowed"; \
		printf '$(DIM)        %s$(RESET)\n' "$(2)"; \
		exit 1; \
	fi
endef

# $(call require-ports,ports,hint)
# --------------------------------
# Example:
#   $(call require-ports,3000|5432,Stop conflicting services)
define require-ports
	@set -eo pipefail; \
	printf '%s\n' '$(1)' | tr '|' '\n' | while IFS= read -r p; do \
		proc=$$(lsof -i :"$$p" -sTCP:LISTEN 2>/dev/null | awk 'NR==2 {print $$2", "$$1}' || true); \
		if [ -n "$$proc" ]; then \
			printf '$(RED)[ERROR]$(RESET) Port already in use: $(YELLOW)%s$(RESET) (pid: %s)\n' "$$p" "$$proc"; \
			printf '$(DIM)        %s$(RESET)\n' "$(2)"; \
			exit 1; \
		fi; \
	done
endef

# $(call confirm,message)
# --------------------------------
# Example:
#   $(call confirm,Deploy to production?)
define confirm
	@printf '$(CYAN)[CONFIRM]$(RESET) %s $(DIM)[y/N]$(RESET) ' '$(1)'; \
	read -r ans; \
	case "$$ans" in [yY]) ;; *) printf '$(DIM)Aborted.$(RESET)\n'; exit 1;; esac
endef

# $(call require-regex,value,pattern,hint)
# --------------------------------
# Example:
#   $(call require-regex,$(VERSION),^[0-9]+\.[0-9]+\.[0-9]+$$,Invalid semver)
define require-regex
	@printf '%s' '$(1)' | grep -qE '$(2)' || { \
		printf '$(RED)[ERROR]$(RESET) Validation failed: $(YELLOW)%s$(RESET) (expected: %s)\n' '$(1)' '$(2)'; \
		printf '$(DIM)        %s$(RESET)\n' '$(3)'; \
		exit 1; \
	}
endef

# Version comparison (base64 encoded AWK script)
_VERSION_CMP_AWK_B64 := __VERSION_CMP_AWK_B64__

# $(call require-version,cmd,min-version,hint)
# --------------------------------
# Example:
#   $(call require-version,node,18.0.0,Install Node.js 18+)
define require-version
	@cmd_ver=$$($(1) --version 2>/dev/null \
		| grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1); \
	if [ -z "$$cmd_ver" ]; then \
		printf '$(RED)[ERROR]$(RESET) Could not detect version: $(YELLOW)%s$(RESET)\n' "$(1)"; \
		printf '$(DIM)        %s$(RESET)\n' "$(3)"; \
		exit 1; \
	fi; \
	cmp=$$(printf '%s' '$(_VERSION_CMP_AWK_B64)' | $(_B64_DEC) | awk -v v1="$$cmd_ver" -v v2="$(2)" -f -); \
	if [ "$$cmp" -lt 0 ]; then \
		printf '$(RED)[ERROR]$(RESET) $(YELLOW)%s$(RESET) version %s < required %s\n' "$(1)" "$$cmd_ver" "$(2)"; \
		printf '$(DIM)        %s$(RESET)\n' "$(3)"; \
		exit 1; \
	fi
endef

# $(call require-memory,min-mb,hint)
# --------------------------------
# Example:
#   $(call require-memory,4096,At least 4GB free memory required)
define require-memory
	@if [ "$(IS_MACOS)" = "Darwin" ]; then \
		_free=$$(vm_stat | awk '/Pages free|Pages inactive/ {gsub(/\./,"",$$NF); sum+=$$NF} END {print int(sum*4096/1024/1024)}'); \
	else \
		_free=$$(awk '/MemAvailable/ {print int($$2/1024)}' /proc/meminfo); \
	fi; \
	if [ "$$_free" -lt "$(1)" ]; then \
		printf '$(RED)[ERROR]$(RESET) Insufficient memory: $(YELLOW)%sMB$(RESET) free (required: %sMB)\n' "$$_free" "$(1)"; \
		printf '$(DIM)        %s$(RESET)\n' "$(2)"; \
		exit 1; \
	fi
endef

# $(call require-storage,min-mb,hint)
# --------------------------------
# Example:
#   $(call require-storage,10240,At least 10GB free disk space required)
define require-storage
	@_free=$$(df -Pm . | awk 'NR==2 {print $$4}'); \
	if [ "$$_free" -lt "$(1)" ]; then \
		printf '$(RED)[ERROR]$(RESET) Insufficient disk space: $(YELLOW)%sMB$(RESET) free (required: %sMB)\n' "$$_free" "$(1)"; \
		printf '$(DIM)        %s$(RESET)\n' "$(2)"; \
		exit 1; \
	fi
endef

# $(call retry,max,delay,command)
# --------------------------------
# Example:
#   $(call retry,3,5,curl -f http://api/health)
define retry
	@_n=0; _max=$(1); _delay=$(2); \
	while true; do \
		if $(3); then break; fi; \
		_n=$$((_n + 1)); \
		if [ $$_n -ge $$_max ]; then \
			printf '$(RED)[ERROR]$(RESET) Failed after %d attempts\n' "$$_max"; \
			exit 1; \
		fi; \
		printf '$(YELLOW)[RETRY]$(RESET) Attempt %d/%d failed, retrying in %ds...\n' "$$_n" "$$_max" "$$_delay"; \
		sleep "$$_delay"; \
	done
endef

# $(call wait-for-port,host,port,timeout)
# --------------------------------
# Example:
#   $(call wait-for-port,localhost,5432,30)
define wait-for-port
	@_host=$(1); _port=$(2); _timeout=$(3); _elapsed=0; \
	printf '$(BLUE)[WAIT]$(RESET) Waiting for %s:%s...\n' "$$_host" "$$_port"; \
	while ! nc -z "$$_host" "$$_port" 2>/dev/null; do \
		sleep 1; \
		_elapsed=$$((_elapsed + 1)); \
		if [ $$_elapsed -ge $$_timeout ]; then \
			printf '$(RED)[ERROR]$(RESET) Timeout waiting for %s:%s\n' "$$_host" "$$_port"; \
			exit 1; \
		fi; \
	done; \
	printf '$(GREEN)[OK]$(RESET) %s:%s is ready\n' "$$_host" "$$_port"
endef

# $(call wait-for-url,url,timeout)
# --------------------------------
# Example:
#   $(call wait-for-url,http://localhost:8080/health,30)
define wait-for-url
	@_url=$(1); _timeout=$(2); _elapsed=0; \
	printf '$(BLUE)[WAIT]$(RESET) Waiting for %s...\n' "$$_url"; \
	while true; do \
		_code=$$(curl -s -o /dev/null -w '%{http_code}' "$$_url" 2>/dev/null || echo 0); \
		if [ "$$_code" -ge 200 ] && [ "$$_code" -lt 300 ]; then break; fi; \
		sleep 1; \
		_elapsed=$$((_elapsed + 1)); \
		if [ $$_elapsed -ge $$_timeout ]; then \
			printf '$(RED)[ERROR]$(RESET) Timeout waiting for %s (last: %s)\n' "$$_url" "$$_code"; \
			exit 1; \
		fi; \
	done; \
	printf '$(GREEN)[OK]$(RESET) %s is ready (HTTP %s)\n' "$$_url" "$$_code"
endef
