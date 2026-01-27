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
	@printf '$(DIM)$$ %s$(RESET)\n' "$(call escape,dq|backtick,$(1))"
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
