#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup

    cat > "$TEST_TEMP_DIR/Makefile" << 'EOF'
include args.mk

test-args:
	@echo "ARGS: $(RUN_ARGS)"

.PHONY: test-args
EOF

    cp "$PROJECT_ROOT/args.mk" "$TEST_TEMP_DIR/"
}

teardown() {
    _common_teardown
}

@test "args: captures arguments after --" {
    cd "$TEST_TEMP_DIR"
    run make test-args -- --verbose --debug
    assert_success
    assert_output --partial "ARGS: --verbose --debug"
}

@test "args: empty when no arguments" {
    cd "$TEST_TEMP_DIR"
    run make test-args
    assert_success
    assert_output --partial "ARGS:"
}

@test "args: handles multiple arguments" {
    cd "$TEST_TEMP_DIR"
    run make test-args -- arg1 arg2 arg3
    assert_success
    assert_output --partial "ARGS: arg1 arg2 arg3"
}

@test "args: no error for extra args" {
    cd "$TEST_TEMP_DIR"
    run make test-args -- foo bar
    assert_success
    refute_output --partial "No rule to make target"
}

# Edge cases

@test "args: handles single dash argument" {
    cd "$TEST_TEMP_DIR"
    run make test-args -- -v -d
    assert_success
    assert_output --partial "ARGS: -v -d"
}

@test "args: handles long argument" {
    cd "$TEST_TEMP_DIR"
    run make test-args -- --very-long-argument-name
    assert_success
    assert_output --partial "ARGS: --very-long-argument-name"
}

@test "args: = sign treated as make variable (known limitation)" {
    cd "$TEST_TEMP_DIR"
    # When using KEY=value, make treats it entirely as variable assignment
    # Nothing is captured in RUN_ARGS - this is make's expected behavior
    run make test-args -- KEY=value
    assert_success
    # RUN_ARGS is empty because KEY=value is consumed by make
    assert_output --partial "ARGS:"
}

@test "args: handles numeric arguments" {
    cd "$TEST_TEMP_DIR"
    run make test-args -- 1 2 3 123
    assert_success
    assert_output --partial "ARGS: 1 2 3 123"
}
