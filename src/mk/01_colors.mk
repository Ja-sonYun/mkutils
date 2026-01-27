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
