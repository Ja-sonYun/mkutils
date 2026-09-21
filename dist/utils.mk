# Makefile utilities

ifndef _UTILS_MK_INCLUDED
_UTILS_MK_INCLUDED := 1

# Use bash for consistent behavior across platforms
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

#
# Colors
#

ifeq ($(NO_COLOR),)
	BLACK       := \033[0;30m
	RED         := \033[0;31m
	GREEN       := \033[0;32m
	YELLOW      := \033[0;33m
	BLUE        := \033[0;34m
	PURPLE      := \033[0;35m
	CYAN        := \033[0;36m
	WHITE       := \033[0;37m
	BOLD        := \033[1m
	BOLD_RED    := \033[1;31m
	BOLD_GREEN  := \033[1;32m
	BOLD_YELLOW := \033[1;33m
	BOLD_BLUE   := \033[1;34m
	BOLD_PURPLE := \033[1;35m
	BOLD_CYAN   := \033[1;36m
	BG_RED      := \033[41m
	BG_GREEN    := \033[42m
	BG_YELLOW   := \033[43m
	BG_BLUE     := \033[44m
	BG_PURPLE   := \033[45m
	BG_CYAN     := \033[46m
	DIM         := \033[2m
	UNDERLINE   := \033[4m
	BLINK       := \033[5m
	REVERSE     := \033[7m
	RESET       := \033[0m
else
	BLACK       :=
	RED         :=
	GREEN       :=
	YELLOW      :=
	BLUE        :=
	PURPLE      :=
	CYAN        :=
	WHITE       :=
	BOLD        :=
	BOLD_RED    :=
	BOLD_GREEN  :=
	BOLD_YELLOW :=
	BOLD_BLUE   :=
	BOLD_PURPLE :=
	BOLD_CYAN   :=
	BG_RED      :=
	BG_GREEN    :=
	BG_YELLOW   :=
	BG_BLUE     :=
	BG_PURPLE   :=
	BG_CYAN     :=
	DIM         :=
	UNDERLINE   :=
	BLINK       :=
	REVERSE     :=
	RESET       :=
endif

#
# OS Detection
#

OS_NAME  := $(shell uname -s)
IS_MACOS := $(filter Darwin,$(OS_NAME))
IS_LINUX := $(filter Linux,$(OS_NAME))

#
# Terminal
#

TERM_WIDTH := $(shell tput cols || echo 80)

#
# Internal utilities
#

COMMA := ,

_FULL_LINE = printf '%*s' $(TERM_WIDTH) '' | tr ' '
_TIME_CMD  := $(shell command -v python3 >/dev/null 2>&1 \
	&& echo "python3 -c 'import time; print(time.time())'" \
	|| echo "date +%s")

# Cross-platform sed -i wrapper (detect GNU vs BSD sed)
_SED_IS_GNU := $(shell sed --version 2>/dev/null | grep -q GNU && echo 1)

# $(call replace,old,new,file)
# --------------------------------
# Example:
#   $(call replace,foo,bar,config.txt)
ifeq ($(_SED_IS_GNU),1)
replace = sed -i 's/$(1)/$(2)/g' $(3)
else
replace = sed -i '' 's/$(1)/$(2)/g' $(3)
endif

# base64 decoder (macOS: base64 -D, Linux: base64 -d)
_B64_DEC := $(shell base64 --help 2>&1 | grep -q GNU && echo 'base64 -d' || echo 'base64 -D')

# Semver version bump (base64 encoded AWK script)
_SEMVER_BUMP_AWK_B64 := QkVHSU4gewoJc3BsaXQodmVyLCB2LCAiLiIpCglpZiAocGFydCA9PSAibWFqb3IiKSB7CgkJdlsxXSsrCgkJdlsyXSA9IDAKCQl2WzNdID0gMAoJfSBlbHNlIGlmIChwYXJ0ID09ICJtaW5vciIpIHsKCQl2WzJdKysKCQl2WzNdID0gMAoJfSBlbHNlIGlmIChwYXJ0ID09ICJwYXRjaCIpIHsKCQl2WzNdKysKCX0KCXByaW50ZiAiJWQuJWQuJWQiLCB2WzFdLCB2WzJdLCB2WzNdCn0K

# $(call semver-bump,major|minor|patch,version)
# --------------------------------
# Example:
#   $(call semver-bump,minor,1.2.3)
semver-bump = $(shell printf '%s' '$(_SEMVER_BUMP_AWK_B64)' | $(_B64_DEC) | awk -v part="$(1)" -v ver="$(2)" -f -)

# String escape (base64 encoded AWK script)
_ESCAPE_AWK_B64 := QkVHSU4gewoJcyA9IEVOVklST05bIl9FIl0KCWlmIChpbmRleChvcHRzLCAiYmFja3NsYXNoIikpIHsKCQlnc3ViKC9cXC8sICJcXFxcIiwgcykKCX0KCWlmIChpbmRleChvcHRzLCAiZHEiKSkgewoJCWdzdWIoLyIvLCAiXFxcIiIsIHMpCgl9CglpZiAoaW5kZXgob3B0cywgInNxIikpIHsKCQlnc3ViKC8nLywgIidcXCcnIiwgcykKCX0KCWlmIChpbmRleChvcHRzLCAiYmFja3RpY2siKSkgewoJCWdzdWIoL2AvLCAiXFxgIiwgcykKCX0KCXByaW50IHMKfQo=

# $(call escape,opts,string)
# --------------------------------
# Example:
#   $(call escape,dq|backtick,packer build -var="name=test")
#   $(call escape,backslash|dq,C:\Users\name)
escape = $(shell _E='$(subst ','"'"',$(2))' sh -c "printf '%s' '$(_ESCAPE_AWK_B64)' | $(_B64_DEC) | awk -v opts='$(1)' -f -")

#
# String
#

# $(call slugify,string)
# --------------------------------
# Example:
#   $(call slugify,Hello World! 123) -> hello-world-123
slugify = $(shell echo '$(1)' | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' '-' | sed 's/^-//;s/-$$//')

# $(call truncate,string,length)
# --------------------------------
# Example:
#   $(call truncate,Hello World,5) -> Hello
truncate = $(shell echo '$(1)' | cut -c1-$(2))

# $(call pad-left,string,length,char)
# --------------------------------
# Example:
#   $(call pad-left,42,5,0) -> 00042
pad-left = $(shell printf '%*s' $(2) '$(1)' | tr ' ' '$(3)')

# $(call pad-right,string,length,char)
# --------------------------------
# Example:
#   $(call pad-right,42,5,0) -> 42000
pad-right = $(shell printf '%-*s' $(2) '$(1)' | tr ' ' '$(3)')

#
# Args: $(RUN_ARGS), $(FIRST_ARG)
#

RUN_ARGS  := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(RUN_ARGS):;@:)
FIRST_ARG := $(firstword $(RUN_ARGS))

#
# Messages
#

# $(call msg-info,message)
# --------------------------------
# Example:
#   $(call msg-info,'Starting build...')
define msg-info
	@printf '$(BLUE)[INFO]$(RESET) %s\n' $(1)
endef

# $(call msg-success,message)
# --------------------------------
# Example:
#   $(call msg-success,'Build completed')
define msg-success
	@printf '$(GREEN)[OK]$(RESET) %s\n' $(1)
endef

# $(call msg-warn,message)
# --------------------------------
# Example:
#   $(call msg-warn,'Cache expired')
define msg-warn
	@printf '$(YELLOW)[WARN]$(RESET) %s\n' $(1)
endef

# $(call msg-error,message)
# --------------------------------
# Example:
#   $(call msg-error,'Build failed')
define msg-error
	@printf '$(RED)[ERROR]$(RESET) %s\n' $(1)
endef

# $(call msg-step,current,total,message)
# --------------------------------
# Example:
#   $(call msg-step,1,5,'Compiling sources')
define msg-step
	@printf '$(BOLD_BLUE)[%s/%s]$(RESET) %s\n' $(1) $(2) $(3)
endef

# $(call msg-header,title)
# --------------------------------
# Example:
#   $(call msg-header,'Build Process')
define msg-header
	@printf '$(CYAN)%s$(RESET)\n' "$$($(_FULL_LINE) '=')"
	@printf '\n$(BOLD_CYAN)  %s$(RESET)\n\n' $(1)
	@printf '$(CYAN)%s$(RESET)\n' "$$($(_FULL_LINE) '=')"
endef

# $(call msg-sep)
# --------------------------------
# Example:
#   $(call msg-sep)
define msg-sep
	@printf '$(DIM)%s$(RESET)\n' "$$($(_FULL_LINE) '-')"
endef

# $(call msg-cmd,command)
# --------------------------------
# Example:
#   $(call msg-cmd,'npm install')
#   $(call msg-cmd,packer build -var="image_type=base")
define msg-cmd
	$(call msg-sep)
	@printf '$(DIM)$$ %s$(RESET)\n' '$(call escape,sq,$(1))'
	$(call msg-sep)
endef

# $(call run-cmd,command)
# --------------------------------
# Example:
#   $(call run-cmd,npm install)
define run-cmd
	$(call msg-cmd,$(1))
	@$(1)
endef

# $(call confirm-run,command[,message])
# --------------------------------
# Example:
#   $(call confirm-run,kubectl apply -f deployment.yaml)
#   $(call confirm-run,rm -rf dist,Delete dist folder?)
define confirm-run
	$(call msg-cmd,$(1))
	$(call confirm,$(if $(2),$(2),Run this command?))
	@$(1)
endef

# $(call msg-status,status,message)
# --------------------------------
# Example:
#   $(call msg-status,PASS,'All tests passed')
define msg-status
	@printf '[$(1)] %s\n' $(2)
endef

# $(call timed,command)
# --------------------------------
# Example:
#   $(call timed,npm run build)
define timed
	@_start=$$($(_TIME_CMD)); \
	set +e; $(1); _rc=$$?; set -e; \
	_end=$$($(_TIME_CMD)); \
	_elapsed=$$(echo "$$_end - $$_start" | bc); \
	if [ $$_rc -eq 0 ]; then \
		printf '$(GREEN)[OK]$(RESET) Done in %ss\n' "$$_elapsed"; \
	else \
		printf '$(RED)[FAIL]$(RESET) Failed in %ss (exit %d)\n' "$$_elapsed" "$$_rc"; \
		exit $$_rc; \
	fi
endef

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
_VERSION_CMP_AWK_B64 := QkVHSU4gewoJc3BsaXQodjEsIGEsICIuIikKCXNwbGl0KHYyLCBiLCAiLiIpCglmb3IgKGkgPSAxOyBpIDw9IDM7IGkrKykgewoJCWlmICgoYVtpXSArIDApIDwgKGJbaV0gKyAwKSkgewoJCQlwcmludCAtMQoJCQlleGl0CgkJfQoJCWlmICgoYVtpXSArIDApID4gKGJbaV0gKyAwKSkgewoJCQlwcmludCAxCgkJCWV4aXQKCQl9Cgl9CglwcmludCAwCn0K

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

#
# Input
#

# Python UI script (base64 encoded)
_UTILS_PY_B64 := aW1wb3J0IGNvZGVjcwppbXBvcnQgb3MKaW1wb3J0IHNlbGVjdAppbXBvcnQgc3lzCgpFU0MgPSAiXHgxYiIKQ1RSTF9DID0gIlx4MDMiCkNUUkxfRCA9ICJceDA0IgoKS0VZUyA9IHsKICAgIEVTQyArICJbQSI6ICJ1cCIsCiAgICBFU0MgKyAiW0IiOiAiZG93biIsCiAgICBFU0MgKyAiW0MiOiAicmlnaHQiLAogICAgRVNDICsgIltEIjogImxlZnQiLAogICAgIlxyIjogImVudGVyIiwKICAgICJcbiI6ICJlbnRlciIsCiAgICBDVFJMX0M6ICJxdWl0IiwKICAgIENUUkxfRDogInF1aXQiLAogICAgIlx4N2YiOiAiYmFja3NwYWNlIiwKICAgICJceDA4IjogImJhY2tzcGFjZSIsCiAgICAiXHgwMSI6ICJob21lIiwKICAgICJceDA1IjogImVuZCIsCiAgICAiXHgxNyI6ICJkZWxldGVfd29yZCIsCn0KClNFTEVDVElPTl9LRVlTID0gewogICAgKipLRVlTLAogICAgImsiOiAidXAiLAogICAgImoiOiAiZG93biIsCiAgICAiICI6ICJ0b2dnbGUiLAogICAgInEiOiAicXVpdCIsCn0KCgpjbGFzcyBBTlNJOgogICAgX25vX2NvbG9yID0gYm9vbChvcy5lbnZpcm9uLmdldCgiTk9fQ09MT1IiLCAiIikpCgogICAgQGNsYXNzbWV0aG9kCiAgICBkZWYgX3dyYXAoY2xzLCBjLCB0KToKICAgICAgICByZXR1cm4gdCBpZiBjbHMuX25vX2NvbG9yIGVsc2UgIlwwMzNbe31te31cMDMzWzBtIi5mb3JtYXQoYywgdCkKCiAgICBAY2xhc3NtZXRob2QKICAgIGRlZiBjeWFuKGNscywgdCk6CiAgICAgICAgcmV0dXJuIGNscy5fd3JhcCgzNiwgdCkKCiAgICBAY2xhc3NtZXRob2QKICAgIGRlZiBncmVlbihjbHMsIHQpOgogICAgICAgIHJldHVybiBjbHMuX3dyYXAoMzIsIHQpCgogICAgQGNsYXNzbWV0aG9kCiAgICBkZWYgcmVkKGNscywgdCk6CiAgICAgICAgcmV0dXJuIGNscy5fd3JhcCgzMSwgdCkKCiAgICBAc3RhdGljbWV0aG9kCiAgICBkZWYgY3Vyc29yX3VwKG49MSk6CiAgICAgICAgcmV0dXJuICJcMDMzW3t9QSIuZm9ybWF0KG4pCgogICAgQHN0YXRpY21ldGhvZAogICAgZGVmIGNsZWFyX2xpbmUoKToKICAgICAgICByZXR1cm4gIlwwMzNbMksiCgogICAgQHN0YXRpY21ldGhvZAogICAgZGVmIGhpZGVfY3Vyc29yKCk6CiAgICAgICAgcmV0dXJuICJcMDMzWz8yNWwiCgogICAgQHN0YXRpY21ldGhvZAogICAgZGVmIHNob3dfY3Vyc29yKCk6CiAgICAgICAgcmV0dXJuICJcMDMzWz8yNWgiCgoKY2xhc3MgVGVybWluYWxXcml0ZXI6CiAgICBkZWYgX19pbml0X18oc2VsZiwgc3RyZWFtKToKICAgICAgICBzZWxmLl9zdHJlYW0gPSBzdHJlYW0KICAgICAgICBzZWxmLl9saW5lcyA9IDAKICAgICAgICBzZWxmLl9wYXJ0aWFsID0gRmFsc2UKCiAgICBkZWYgd3JpdGUoc2VsZiwgdCk6CiAgICAgICAgc2VsZi5fc3RyZWFtLndyaXRlKHQpCiAgICAgICAgaWYgdDoKICAgICAgICAgICAgc2VsZi5fbGluZXMgKz0gdC5jb3VudCgiXG4iKQogICAgICAgICAgICBzZWxmLl9wYXJ0aWFsID0gbm90IHQuZW5kc3dpdGgoIlxuIikKCiAgICBkZWYgd3JpdGVsbihzZWxmLCB0PSIiKToKICAgICAgICBzZWxmLl9zdHJlYW0ud3JpdGUoQU5TSS5jbGVhcl9saW5lKCkgKyB0ICsgIlxuIikKICAgICAgICBzZWxmLl9saW5lcyArPSAxCiAgICAgICAgc2VsZi5fcGFydGlhbCA9IEZhbHNlCgogICAgZGVmIGZsdXNoKHNlbGYpOgogICAgICAgIHNlbGYuX3N0cmVhbS5mbHVzaCgpCgogICAgZGVmIGNsZWFyKHNlbGYpOgogICAgICAgIGlmIHNlbGYuX2xpbmVzID4gMCBvciBzZWxmLl9wYXJ0aWFsOgogICAgICAgICAgICBpZiBzZWxmLl9saW5lcyA+IDA6CiAgICAgICAgICAgICAgICBzZWxmLl9zdHJlYW0ud3JpdGUoQU5TSS5jdXJzb3JfdXAoc2VsZi5fbGluZXMpKQogICAgICAgICAgICBzZWxmLl9zdHJlYW0ud3JpdGUoIlxyXDAzM1tKIikKICAgICAgICBzZWxmLl9saW5lcyA9IDAKICAgICAgICBzZWxmLl9wYXJ0aWFsID0gRmFsc2UKCgpkZWYgY2hhcl93aWR0aChjaCk6CiAgICBjcCA9IG9yZChjaCkKICAgIGlmIGNwIDwgMHgxMTAwOgogICAgICAgIHJldHVybiAxCiAgICBpZiAweDExMDAgPD0gY3AgPD0gMHgxMTVGOiAgIyBIYW5ndWwgSmFtbwogICAgICAgIHJldHVybiAyCiAgICBpZiAweDJFODAgPD0gY3AgPD0gMHhBNENGOiAgIyBDSksgUmFkaWNhbHMgfiBDSksgQ29tcGF0CiAgICAgICAgcmV0dXJuIDIKICAgIGlmIDB4QUMwMCA8PSBjcCA8PSAweEQ3QTM6ICAjIEhhbmd1bCBTeWxsYWJsZXMKICAgICAgICByZXR1cm4gMgogICAgaWYgMHhGOTAwIDw9IGNwIDw9IDB4RkFGRjogICMgQ0pLIENvbXBhdCBJZGVvZ3JhcGhzCiAgICAgICAgcmV0dXJuIDIKICAgIGlmIDB4RkUxMCA8PSBjcCA8PSAweEZFNkY6ICAjIFZlcnRpY2FsL0NKSyBDb21wYXQgRm9ybXMKICAgICAgICByZXR1cm4gMgogICAgaWYgMHhGRjAwIDw9IGNwIDw9IDB4RkY2MDogICMgRnVsbHdpZHRoIEZvcm1zCiAgICAgICAgcmV0dXJuIDIKICAgIGlmIDB4RkZFMCA8PSBjcCA8PSAweEZGRTY6ICAjIEZ1bGx3aWR0aCBTeW1ib2xzCiAgICAgICAgcmV0dXJuIDIKICAgIGlmIDB4MjAwMDAgPD0gY3AgPD0gMHgyRkZGRDogICMgQ0pLIEV4dGVuc2lvbiBCLUYKICAgICAgICByZXR1cm4gMgogICAgcmV0dXJuIDEKCgpkZWYgc3RyX3dpZHRoKHMpOgogICAgcmV0dXJuIHN1bShjaGFyX3dpZHRoKGMpIGZvciBjIGluIHMpCgoKZGVmIGdldF9rZXkoKSAtPiBzdHI6CiAgICBpbXBvcnQgdGVybWlvcwogICAgaW1wb3J0IHR0eQoKICAgIGZkID0gc3lzLnN0ZGluLmZpbGVubygpCiAgICBvbGQgPSB0ZXJtaW9zLnRjZ2V0YXR0cihmZCkKICAgIHRyeToKICAgICAgICB0dHkuc2V0cmF3KGZkLCB0ZXJtaW9zLlRDU0FOT1cpCiAgICAgICAgZGVjb2RlciA9IGNvZGVjcy5nZXRpbmNyZW1lbnRhbGRlY29kZXIoc3lzLnN0ZGluLmVuY29kaW5nIG9yICJ1dGYtOCIpKAogICAgICAgICAgICBlcnJvcnM9InJlcGxhY2UiCiAgICAgICAgKQogICAgICAgIGNoID0gIiIKICAgICAgICB3aGlsZSBub3QgY2g6CiAgICAgICAgICAgIGRhdGEgPSBvcy5yZWFkKGZkLCAxKQogICAgICAgICAgICBpZiBub3QgZGF0YToKICAgICAgICAgICAgICAgIHJldHVybiBDVFJMX0QKICAgICAgICAgICAgY2ggPSBkZWNvZGVyLmRlY29kZShkYXRhKQogICAgICAgIGlmIGNoID09IEVTQzoKICAgICAgICAgICAgZm9yIF8gaW4gcmFuZ2UoMik6CiAgICAgICAgICAgICAgICBpZiBub3Qgc2VsZWN0LnNlbGVjdChbZmRdLCBbXSwgW10sIDAuMDMpWzBdOgogICAgICAgICAgICAgICAgICAgIGJyZWFrCiAgICAgICAgICAgICAgICBjaCArPSBvcy5yZWFkKGZkLCAxKS5kZWNvZGUoImFzY2lpIiwgZXJyb3JzPSJyZXBsYWNlIikKICAgICAgICByZXR1cm4gY2gKICAgIGZpbmFsbHk6CiAgICAgICAgdGVybWlvcy50Y3NldGF0dHIoZmQsIHRlcm1pb3MuVENTQURSQUlOLCBvbGQpCgoKZGVmIHBhcnNlX29wdGlvbihyYXcpOgogICAgaWYgcmF3LmVuZHN3aXRoKCJdIikgYW5kICJbIiBpbiByYXc6CiAgICAgICAgaWR4ID0gcmF3LnJmaW5kKCJbIikKICAgICAgICBpZiBpZHggPj0gMDoKICAgICAgICAgICAgcmV0dXJuIHJhd1s6aWR4XSwgcmF3W2lkeCArIDEgOiAtMV0KICAgIHJldHVybiByYXcsICIiCgoKZGVmIHBhcnNlX29wdGlvbnMocmF3X29wdGlvbnMpOgogICAgcmV0dXJuIFt7InZhbHVlIjogdiwgImRlc2MiOiBkfSBmb3IgdiwgZCBpbiAocGFyc2Vfb3B0aW9uKG8pIGZvciBvIGluIHJhd19vcHRpb25zKV0KCgpkZWYgb3B0aW9uX2xhYmVsKG9wdCk6CiAgICBpZiBvcHRbImRlc2MiXToKICAgICAgICByZXR1cm4gInt9IC0ge30iLmZvcm1hdChvcHRbInZhbHVlIl0sIG9wdFsiZGVzYyJdKQogICAgcmV0dXJuIG9wdFsidmFsdWUiXQoKCmRlZiBzZWxlY3RfdWkob3B0aW9ucywgcHJvbXB0LCBkZWZhdWx0KToKICAgIHBhcnNlZCA9IHBhcnNlX29wdGlvbnMob3B0aW9ucykKICAgIHZhbHVlcyA9IFtvWyJ2YWx1ZSJdIGZvciBvIGluIHBhcnNlZF0KICAgIGlmIG5vdCBzeXMuc3RkaW4uaXNhdHR5KCk6CiAgICAgICAgcmV0dXJuIGRlZmF1bHQgaWYgZGVmYXVsdCBpbiB2YWx1ZXMgZWxzZSB2YWx1ZXNbMF0KICAgIGlkeCA9IHZhbHVlcy5pbmRleChkZWZhdWx0KSBpZiBkZWZhdWx0IGluIHZhbHVlcyBlbHNlIDAKICAgIG4gPSBsZW4ocGFyc2VkKQogICAgdyA9IFRlcm1pbmFsV3JpdGVyKHN5cy5zdGRlcnIpCgogICAgZGVmIHJlbmRlcihmaXJzdD1GYWxzZSk6CiAgICAgICAgaWYgbm90IGZpcnN0OgogICAgICAgICAgICB3LmNsZWFyKCkKICAgICAgICB3LndyaXRlbG4oQU5TSS5jeWFuKCJbP10iKSArICIge306Ii5mb3JtYXQocHJvbXB0KSkKICAgICAgICBmb3IgaSwgb3B0IGluIGVudW1lcmF0ZShwYXJzZWQpOgogICAgICAgICAgICBsYWJlbCA9IG9wdGlvbl9sYWJlbChvcHQpCiAgICAgICAgICAgIHcud3JpdGUoQU5TSS5jeWFuKCI+ICIgKyBsYWJlbCkgaWYgaSA9PSBpZHggZWxzZSAiICAiICsgbGFiZWwpCiAgICAgICAgICAgIGlmIGkgPCBuIC0gMToKICAgICAgICAgICAgICAgIHcud3JpdGUoIlxuIikKICAgICAgICB3LmZsdXNoKCkKCiAgICBzeXMuc3RkZXJyLndyaXRlKEFOU0kuaGlkZV9jdXJzb3IoKSkKICAgIHJlbmRlcihmaXJzdD1UcnVlKQogICAgd2hpbGUgVHJ1ZToKICAgICAgICBrZXkgPSBTRUxFQ1RJT05fS0VZUy5nZXQoZ2V0X2tleSgpKQogICAgICAgIGlmIGtleSA9PSAidXAiOgogICAgICAgICAgICBpZHggPSAoaWR4IC0gMSkgJSBuCiAgICAgICAgZWxpZiBrZXkgPT0gImRvd24iOgogICAgICAgICAgICBpZHggPSAoaWR4ICsgMSkgJSBuCiAgICAgICAgZWxpZiBrZXkgPT0gImVudGVyIjoKICAgICAgICAgICAgYnJlYWsKICAgICAgICBlbGlmIGtleSA9PSAicXVpdCI6CiAgICAgICAgICAgIHN5cy5zdGRlcnIud3JpdGUoQU5TSS5zaG93X2N1cnNvcigpICsgIlxuIiArIEFOU0kucmVkKCJBYm9ydGVkLiIpICsgIlxuIikKICAgICAgICAgICAgc3lzLmV4aXQoMSkKICAgICAgICByZW5kZXIoKQogICAgdy5jbGVhcigpCiAgICBzeXMuc3RkZXJyLndyaXRlKAogICAgICAgIEFOU0kuc2hvd19jdXJzb3IoKQogICAgICAgICsgQU5TSS5ncmVlbigiW09LXSIpCiAgICAgICAgKyAiIHt9OiB7fVxuIi5mb3JtYXQocHJvbXB0LCB2YWx1ZXNbaWR4XSkKICAgICkKICAgIHJldHVybiB2YWx1ZXNbaWR4XQoKCmRlZiBzZWxlY3RfbXVsdGlfdWkob3B0aW9ucywgcHJvbXB0LCBkZWZhdWx0cyk6CiAgICBwYXJzZWQgPSBwYXJzZV9vcHRpb25zKG9wdGlvbnMpCiAgICB2YWx1ZXMgPSBbb1sidmFsdWUiXSBmb3IgbyBpbiBwYXJzZWRdCiAgICBpZiBub3Qgc3lzLnN0ZGluLmlzYXR0eSgpOgogICAgICAgIHJldHVybiBkZWZhdWx0cyBpZiBkZWZhdWx0cyBlbHNlIFtdCiAgICBzZWxlY3RlZCA9IHNldChpIGZvciBpLCB2IGluIGVudW1lcmF0ZSh2YWx1ZXMpIGlmIHYgaW4gc2V0KGRlZmF1bHRzIG9yIFtdKSkKICAgIGlkeCwgbiA9IDAsIGxlbihwYXJzZWQpCiAgICB3ID0gVGVybWluYWxXcml0ZXIoc3lzLnN0ZGVycikKCiAgICBkZWYgcmVuZGVyKGZpcnN0PUZhbHNlKToKICAgICAgICBpZiBub3QgZmlyc3Q6CiAgICAgICAgICAgIHcuY2xlYXIoKQogICAgICAgIHcud3JpdGVsbihBTlNJLmN5YW4oIls/XSIpICsgIiB7fToiLmZvcm1hdChwcm9tcHQpKQogICAgICAgIGZvciBpLCBvcHQgaW4gZW51bWVyYXRlKHBhcnNlZCk6CiAgICAgICAgICAgIGxhYmVsID0gb3B0aW9uX2xhYmVsKG9wdCkKICAgICAgICAgICAgY2hrID0gIlt4XSIgaWYgaSBpbiBzZWxlY3RlZCBlbHNlICJbIF0iCiAgICAgICAgICAgIHcud3JpdGUoCiAgICAgICAgICAgICAgICBBTlNJLmN5YW4oIj4ge30ge30iLmZvcm1hdChjaGssIGxhYmVsKSkKICAgICAgICAgICAgICAgIGlmIGkgPT0gaWR4CiAgICAgICAgICAgICAgICBlbHNlICIgIHt9IHt9Ii5mb3JtYXQoY2hrLCBsYWJlbCkKICAgICAgICAgICAgKQogICAgICAgICAgICBpZiBpIDwgbiAtIDE6CiAgICAgICAgICAgICAgICB3LndyaXRlKCJcbiIpCiAgICAgICAgdy5mbHVzaCgpCgogICAgc3lzLnN0ZGVyci53cml0ZShBTlNJLmhpZGVfY3Vyc29yKCkpCiAgICByZW5kZXIoZmlyc3Q9VHJ1ZSkKICAgIHdoaWxlIFRydWU6CiAgICAgICAga2V5ID0gU0VMRUNUSU9OX0tFWVMuZ2V0KGdldF9rZXkoKSkKICAgICAgICBpZiBrZXkgPT0gInVwIjoKICAgICAgICAgICAgaWR4ID0gKGlkeCAtIDEpICUgbgogICAgICAgIGVsaWYga2V5ID09ICJkb3duIjoKICAgICAgICAgICAgaWR4ID0gKGlkeCArIDEpICUgbgogICAgICAgIGVsaWYga2V5ID09ICJ0b2dnbGUiOgogICAgICAgICAgICBzZWxlY3RlZC5zeW1tZXRyaWNfZGlmZmVyZW5jZV91cGRhdGUoe2lkeH0pCiAgICAgICAgZWxpZiBrZXkgPT0gImVudGVyIjoKICAgICAgICAgICAgYnJlYWsKICAgICAgICBlbGlmIGtleSA9PSAicXVpdCI6CiAgICAgICAgICAgIHN5cy5zdGRlcnIud3JpdGUoQU5TSS5zaG93X2N1cnNvcigpICsgIlxuIiArIEFOU0kucmVkKCJBYm9ydGVkLiIpICsgIlxuIikKICAgICAgICAgICAgc3lzLmV4aXQoMSkKICAgICAgICByZW5kZXIoKQogICAgdy5jbGVhcigpCiAgICByZXN1bHQgPSBbdmFsdWVzW2ldIGZvciBpIGluIHNvcnRlZChzZWxlY3RlZCldCiAgICBzeXMuc3RkZXJyLndyaXRlKAogICAgICAgIEFOU0kuc2hvd19jdXJzb3IoKQogICAgICAgICsgQU5TSS5ncmVlbigiW09LXSIpCiAgICAgICAgKyAiIHt9OiB7fVxuIi5mb3JtYXQocHJvbXB0LCAiLCAiLmpvaW4ocmVzdWx0KSBvciAiKG5vbmUpIikKICAgICkKICAgIHJldHVybiByZXN1bHQKCgpkZWYgaW5wdXRfdWkocHJvbXB0OiBzdHIsIGRlZmF1bHQ6IHN0ciA9ICIiKSAtPiBzdHI6CiAgICBpZiBub3Qgc3lzLnN0ZGluLmlzYXR0eSgpOgogICAgICAgIHJldHVybiBkZWZhdWx0CiAgICBidWYsIGN1ciA9IGxpc3QoZGVmYXVsdCksIGxlbihkZWZhdWx0KQogICAgcHQgPSBBTlNJLmN5YW4oIls/XSIpICsgIiB7fTogIi5mb3JtYXQocHJvbXB0KQogICAgd2hpbGUgVHJ1ZToKICAgICAgICB0ID0gIiIuam9pbihidWYpCiAgICAgICAgc3lzLnN0ZGVyci53cml0ZSgiXHIiICsgQU5TSS5jbGVhcl9saW5lKCkgKyBwdCArIHQpCiAgICAgICAgaWYgY3VyIDwgbGVuKGJ1Zik6CiAgICAgICAgICAgIHN5cy5zdGRlcnIud3JpdGUoIlwwMzNbe31EIi5mb3JtYXQoc3RyX3dpZHRoKCIiLmpvaW4oYnVmW2N1cjpdKSkpKQogICAgICAgIHN5cy5zdGRlcnIuZmx1c2goKQogICAgICAgIGtleSA9IGdldF9rZXkoKQogICAgICAgIGFjdCA9IEtFWVMuZ2V0KGtleSkKICAgICAgICBpZiBhY3QgPT0gImVudGVyIjoKICAgICAgICAgICAgYnJlYWsKICAgICAgICBlbGlmIGFjdCA9PSAicXVpdCI6CiAgICAgICAgICAgIHN5cy5zdGRlcnIud3JpdGUoIlxuIiArIEFOU0kucmVkKCJBYm9ydGVkLiIpICsgIlxuIikKICAgICAgICAgICAgc3lzLmV4aXQoMSkKICAgICAgICBlbGlmIGFjdCA9PSAibGVmdCIgYW5kIGN1ciA+IDA6CiAgICAgICAgICAgIGN1ciAtPSAxCiAgICAgICAgZWxpZiBhY3QgPT0gInJpZ2h0IiBhbmQgY3VyIDwgbGVuKGJ1Zik6CiAgICAgICAgICAgIGN1ciArPSAxCiAgICAgICAgZWxpZiBhY3QgPT0gImhvbWUiOgogICAgICAgICAgICBjdXIgPSAwCiAgICAgICAgZWxpZiBhY3QgPT0gImVuZCI6CiAgICAgICAgICAgIGN1ciA9IGxlbihidWYpCiAgICAgICAgZWxpZiBhY3QgPT0gImJhY2tzcGFjZSIgYW5kIGN1ciA+IDA6CiAgICAgICAgICAgIGJ1Zi5wb3AoY3VyIC0gMSkKICAgICAgICAgICAgY3VyIC09IDEKICAgICAgICBlbGlmIGFjdCA9PSAiZGVsZXRlX3dvcmQiIGFuZCBjdXIgPiAwOgogICAgICAgICAgICB3aGlsZSBjdXIgPiAwIGFuZCBub3QgKGJ1ZltjdXIgLSAxXS5pc2FsbnVtKCkgb3IgYnVmW2N1ciAtIDFdID09ICJfIik6CiAgICAgICAgICAgICAgICBidWYucG9wKGN1ciAtIDEpCiAgICAgICAgICAgICAgICBjdXIgLT0gMQogICAgICAgICAgICB3aGlsZSBjdXIgPiAwIGFuZCAoYnVmW2N1ciAtIDFdLmlzYWxudW0oKSBvciBidWZbY3VyIC0gMV0gPT0gIl8iKToKICAgICAgICAgICAgICAgIGJ1Zi5wb3AoY3VyIC0gMSkKICAgICAgICAgICAgICAgIGN1ciAtPSAxCiAgICAgICAgZWxpZiBrZXkgYW5kIGxlbihrZXkpID09IDEgYW5kIGtleS5pc3ByaW50YWJsZSgpOgogICAgICAgICAgICBidWYuaW5zZXJ0KGN1ciwga2V5KQogICAgICAgICAgICBjdXIgKz0gMQogICAgcmVzdWx0ID0gIiIuam9pbihidWYpIG9yIGRlZmF1bHQKICAgIHN5cy5zdGRlcnIud3JpdGUoCiAgICAgICAgIlxyIgogICAgICAgICsgQU5TSS5jbGVhcl9saW5lKCkKICAgICAgICArIEFOU0kuZ3JlZW4oIltPS10iKQogICAgICAgICsgIiB7fToge31cbiIuZm9ybWF0KHByb21wdCwgcmVzdWx0KQogICAgKQogICAgcmV0dXJuIHJlc3VsdAoKCmlmIF9fbmFtZV9fID09ICJfX21haW5fXyI6CiAgICBpZiBsZW4oc3lzLmFyZ3YpIDwgMjoKICAgICAgICBzeXMuZXhpdCgxKQogICAgY21kID0gc3lzLmFyZ3ZbMV0KICAgIGlmIGNtZCA9PSAic2VsZWN0IjoKICAgICAgICBwcmludCgKICAgICAgICAgICAgc2VsZWN0X3VpKAogICAgICAgICAgICAgICAgc3lzLmFyZ3ZbMl0uc3BsaXQoInwiKSwKICAgICAgICAgICAgICAgIHN5cy5hcmd2WzNdIGlmIGxlbihzeXMuYXJndikgPiAzIGVsc2UgIlNlbGVjdCIsCiAgICAgICAgICAgICAgICBzeXMuYXJndls0XSBpZiBsZW4oc3lzLmFyZ3YpID4gNCBlbHNlICIiLAogICAgICAgICAgICApCiAgICAgICAgKQogICAgZWxpZiBjbWQgPT0gInNlbGVjdC1tdWx0aSI6CiAgICAgICAgZm9yIGkgaW4gc2VsZWN0X211bHRpX3VpKAogICAgICAgICAgICBzeXMuYXJndlsyXS5zcGxpdCgifCIpLAogICAgICAgICAgICBzeXMuYXJndlszXSBpZiBsZW4oc3lzLmFyZ3YpID4gMyBlbHNlICJTZWxlY3QiLAogICAgICAgICAgICBzeXMuYXJndls0XS5zcGxpdCgifCIpIGlmIGxlbihzeXMuYXJndikgPiA0IGVsc2UgW10sCiAgICAgICAgKToKICAgICAgICAgICAgcHJpbnQoaSkKICAgIGVsaWYgY21kID09ICJpbnB1dCI6CiAgICAgICAgcHJpbnQoCiAgICAgICAgICAgIGlucHV0X3VpKAogICAgICAgICAgICAgICAgc3lzLmFyZ3ZbMl0gaWYgbGVuKHN5cy5hcmd2KSA+IDIgZWxzZSAiSW5wdXQiLAogICAgICAgICAgICAgICAgc3lzLmFyZ3ZbM10gaWYgbGVuKHN5cy5hcmd2KSA+IDMgZWxzZSAiIiwKICAgICAgICAgICAgKQogICAgICAgICkK

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
$(eval _dt_cmd   := $(if $(6),(cd "$(6)" && $(2)),$(2)))

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
$(eval _dth_cmd  := $(if $(6),(cd "$(6)" && $(2)),$(2)))

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
_HELP_AWK_B64 := QkVHSU4gewoJRlMgPSAiOi4qIyMgIgoJaWYgKG5vX2NvbG9yID09ICIiIHx8IG5vX2NvbG9yID09ICIwIikgewoJCUNfUkVTRVQgPSAiXDAzM1swbSIKCQlDX0JPTEQgPSAiXDAzM1sxbSIKCQlDX0RJTSA9ICJcMDMzWzJtIgoJCUNfR1JFRU4gPSAiXDAzM1swOzMybSIKCQlDX1lFTExPVyA9ICJcMDMzWzA7MzNtIgoJCUNfQkxVRSA9ICJcMDMzWzA7MzRtIgoJCUNfQ1lBTiA9ICJcMDMzWzA7MzZtIgoJfQoJaWYgKHByb2plY3QgPT0gIiIpIHsKCQlwcm9qZWN0ID0gIlByb2plY3QiCgl9CglpZiAod2lkdGggPT0gIiIpIHsKCQl3aWR0aCA9IDIwCgl9CgljYXRfY291bnQgPSAwCgl0YXJnZXRfY291bnQgPSAwCgljdXJyZW50X2NhdCA9ICIiCn0KCi9eIyNALyB7CgljdXJyZW50X2NhdCA9IHN1YnN0cigkMCwgNSkKCWlmICghIChjdXJyZW50X2NhdCBpbiBjYXRfc2VlbikpIHsKCQljYXRfc2VlbltjdXJyZW50X2NhdF0gPSAxCgkJY2F0X29yZGVyWysrY2F0X2NvdW50XSA9IGN1cnJlbnRfY2F0Cgl9CgluZXh0Cn0KCi9eW2EtekEtWjAtOV8tXSs6Lio/IyMgLyB7Cgl0YXJnZXQgPSAkMQoJZGVzYyA9ICQyCgl0YXJnZXRfb3JkZXJbKyt0YXJnZXRfY291bnRdID0gdGFyZ2V0Cgl0YXJnZXRfZGVzY1t0YXJnZXRdID0gZGVzYwoJdGFyZ2V0X2NhdFt0YXJnZXRdID0gY3VycmVudF9jYXQKfQoKRU5EIHsKCXByaW50ZiAiJXMlcyVzJXMiLCBDX0JPTEQsIENfQkxVRSwgcHJvamVjdCwgQ19SRVNFVAoJaWYgKHZlcnNpb24gIT0gIiIpIHsKCQlwcmludGYgIiAlc3YlcyVzIiwgQ19ESU0sIHZlcnNpb24sIENfUkVTRVQKCX0KCXByaW50ZiAiXG4iCglpZiAoZGVzY3JpcHRpb24gIT0gIiIpIHsKCQlwcmludGYgIiVzIiwgQ19ESU0KCQluID0gc3BsaXQoZGVzY3JpcHRpb24sIGxpbmVzLCAiXG4iKQoJCWZvciAoaSA9IDE7IGkgPD0gbjsgaSsrKSB7CgkJCXByaW50ZiAiICAlc1xuIiwgbGluZXNbaV0KCQl9CgkJcHJpbnRmICIlcyIsIENfUkVTRVQKCX0gZWxzZSB7CgkJcHJpbnRmICJcbiIKCX0KCXByaW50ZiAiJXNVc2FnZTolcyBtYWtlIFt0YXJnZXRdIFtWQVJJQUJMRT12YWx1ZV1cblxuIiwgQ19ZRUxMT1csIENfUkVTRVQKCWlmIChleGFtcGxlcyAhPSAiIikgewoJCXByaW50ZiAiJXNFeGFtcGxlczolc1xuJXMiLCBDX1lFTExPVywgQ19SRVNFVCwgQ19ESU0KCQluID0gc3BsaXQoZXhhbXBsZXMsIGxpbmVzLCAiXG4iKQoJCWZvciAoaSA9IDE7IGkgPD0gbjsgaSsrKSB7CgkJCXByaW50ZiAiICAlc1xuIiwgbGluZXNbaV0KCQl9CgkJcHJpbnRmICIlc1xuIiwgQ19SRVNFVAoJfQoJaWYgKHZhcmlhYmxlcyAhPSAiIikgewoJCXByaW50ZiAiJXNWYXJpYWJsZXM6JXNcbiVzIiwgQ19ZRUxMT1csIENfUkVTRVQsIENfRElNCgkJbiA9IHNwbGl0KHZhcmlhYmxlcywgbGluZXMsICJcbiIpCgkJZm9yIChpID0gMTsgaSA8PSBuOyBpKyspIHsKCQkJcHJpbnRmICIgICVzXG4iLCBsaW5lc1tpXQoJCX0KCQlwcmludGYgIiVzXG4iLCBDX1JFU0VUCgl9CglwcmludGYgIiVzVGFyZ2V0czolc1xuIiwgQ19ZRUxMT1csIENfUkVTRVQKCWZvciAoaSA9IDE7IGkgPD0gdGFyZ2V0X2NvdW50OyBpKyspIHsKCQl0ID0gdGFyZ2V0X29yZGVyW2ldCgkJY2F0ID0gdGFyZ2V0X2NhdFt0XQoJCWlmICghIChjYXQgaW4gcHJpbnRlZF9jYXQpKSB7CgkJCXByaW50ZWRfY2F0W2NhdF0gPSAxCgkJCWlmIChjYXQgIT0gIiIpIHsKCQkJCXByaW50ZiAiXG4gICVzJXMlc1xuIiwgQ19DWUFOLCBjYXQsIENfUkVTRVQKCQkJfQoJCX0KCQlwcmludGYgIiAgICAlcyUtKnMlcyAlc1xuIiwgQ19HUkVFTiwgd2lkdGgsIHQsIENfUkVTRVQsIHRhcmdldF9kZXNjW3RdCgl9CglwcmludGYgIlxuIgp9Cg==

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

endif
