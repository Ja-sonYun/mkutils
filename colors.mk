# colors.mk - Easy color module for Makefile

# Check for NO_COLOR environment variable
ifeq ($(NO_COLOR),)
  # Basic colors
  BLACK   := \033[0;30m
  RED     := \033[0;31m
  GREEN   := \033[0;32m
  YELLOW  := \033[0;33m
  BLUE    := \033[0;34m
  PURPLE  := \033[0;35m
  CYAN    := \033[0;36m
  WHITE   := \033[0;37m

  # Bold colors
  BOLD       := \033[1m
  BOLD_RED   := \033[1;31m
  BOLD_GREEN := \033[1;32m
  BOLD_YELLOW:= \033[1;33m
  BOLD_BLUE  := \033[1;34m
  BOLD_PURPLE:= \033[1;35m
  BOLD_CYAN  := \033[1;36m

  # Background colors
  BG_RED    := \033[41m
  BG_GREEN  := \033[42m
  BG_YELLOW := \033[43m
  BG_BLUE   := \033[44m
  BG_PURPLE := \033[45m
  BG_CYAN   := \033[46m

  # Special styles
  DIM       := \033[2m
  UNDERLINE := \033[4m
  BLINK     := \033[5m
  REVERSE   := \033[7m

  # Reset
  RESET := \033[0m
else
  # No colors when NO_COLOR is set
  BLACK      :=
  RED        :=
  GREEN      :=
  YELLOW     :=
  BLUE       :=
  PURPLE     :=
  CYAN       :=
  WHITE      :=
  BOLD       :=
  BOLD_RED   :=
  BOLD_GREEN :=
  BOLD_YELLOW:=
  BOLD_BLUE  :=
  BOLD_PURPLE:=
  BOLD_CYAN  :=
  BG_RED     :=
  BG_GREEN   :=
  BG_YELLOW  :=
  BG_BLUE    :=
  BG_PURPLE  :=
  BG_CYAN    :=
  DIM        :=
  UNDERLINE  :=
  BLINK      :=
  REVERSE    :=
  RESET      :=
endif

# Helper functions for common patterns
# Usage: $(call print_info,message)
define print_info
	@printf '$(BLUE)[INFO]$(RESET) %s\n' $(1)
endef

# Usage: $(call print_success,message)
define print_success
	@printf '$(GREEN)[OK]$(RESET) %s\n' $(1)
endef

# Usage: $(call print_warning,message)
define print_warning
	@printf '$(YELLOW)[WARN]$(RESET) %s\n' $(1)
endef

# Usage: $(call print_error,message)
define print_error
	@printf '$(RED)[ERROR]$(RESET) %s\n' $(1)
endef

# Usage: $(call print_step,step_number,message)
define print_step
	@printf '$(BOLD_BLUE)[%s/%s]$(RESET) %s\n' $(1) $(2) $(3)
endef

# Usage: $(call print_header,title)
define print_header
	@printf '\n$(BOLD_CYAN)%s$(RESET)\n' $(1)
	@printf '$(CYAN)%s$(RESET)\n' "$$(printf '%*s' $$(printf '%s' $(1) | wc -c) '' | tr ' ' '=')"
endef

# Usage: $(call print_status,status,message)
define print_status
	@printf '[$(1)] %s\n' $(2)
endef

.PHONY: all clean test
