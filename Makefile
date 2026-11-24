.DEFAULT_GOAL := build
.PHONY: build test

build:
	./build.sh

test: build
	env -u MAKEFILES PATH="$(if $(filter /%,$(MAKE_COMMAND)),$(dir $(MAKE_COMMAND)):)$$PATH" bats tests/*.bats
