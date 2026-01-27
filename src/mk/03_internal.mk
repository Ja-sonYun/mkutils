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
_SEMVER_BUMP_AWK_B64 := __SEMVER_BUMP_AWK_B64__

# $(call semver-bump,major|minor|patch,version)
# --------------------------------
# Example:
#   $(call semver-bump,minor,1.2.3)
semver-bump = $(shell printf '%s' '$(_SEMVER_BUMP_AWK_B64)' | $(_B64_DEC) | awk -v part="$(1)" -v ver="$(2)" -f -)

# String escape (base64 encoded AWK script)
_ESCAPE_AWK_B64 := __ESCAPE_AWK_B64__

# $(call escape,opts,string)
# --------------------------------
# Example:
#   $(call escape,dq|backtick,packer build -var="name=test")
#   $(call escape,backslash|dq,C:\Users\name)
escape = $(shell _E='$(subst ','"'"',$(2))' sh -c "printf '%s' '$(_ESCAPE_AWK_B64)' | $(_B64_DEC) | awk -v opts='$(1)' -f -")
