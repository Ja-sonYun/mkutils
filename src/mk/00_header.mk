# Makefile utilities

ifndef _UTILS_MK_INCLUDED
_UTILS_MK_INCLUDED := 1

# Use bash for consistent behavior across platforms
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
