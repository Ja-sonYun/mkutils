.DEFAULT_GOAL := build
.PHONY: build test

build:
	./build.sh

test:
	bats tests/*.bats
