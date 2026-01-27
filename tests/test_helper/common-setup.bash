#!/usr/bin/env bash

_common_setup() {
    bats_load_library bats-support
    bats_load_library bats-assert

    PROJECT_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
    export PROJECT_ROOT

    TEST_TEMP_DIR="$(mktemp -d)"
    export TEST_TEMP_DIR

    export MAKEFLAGS="--no-print-directory"
}

_common_teardown() {
    if [[ -d "$TEST_TEMP_DIR" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}
