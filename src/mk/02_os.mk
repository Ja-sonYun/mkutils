#
# OS Detection
#

OS_NAME  := $(shell uname -s)
IS_MACOS := $(filter Darwin,$(OS_NAME))
IS_LINUX := $(filter Linux,$(OS_NAME))
