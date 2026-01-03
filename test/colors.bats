#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup

    cat > "$TEST_TEMP_DIR/Makefile" << 'EOF'
include colors.mk

test-red:
	@printf '$(RED)red$(RESET)\n'

test-print-info:
	$(call print_info,"Test message")

test-print-success:
	$(call print_success,"Success")

test-print-warning:
	$(call print_warning,"Warning")

test-print-error:
	$(call print_error,"Error")

test-print-step:
	$(call print_step,1,3,"Step")

test-print-header:
	$(call print_header,"Title")

test-print-status:
	$(call print_status,CUSTOM,"Status message")

test-green:
	@printf '$(GREEN)green$(RESET)\n'

.PHONY: test-red test-print-info test-print-success test-print-warning test-print-error test-print-step test-print-header test-print-status test-green
EOF

    cp "$PROJECT_ROOT/colors.mk" "$TEST_TEMP_DIR/"
}

teardown() {
    _common_teardown
}

@test "colors: outputs ANSI codes when NO_COLOR not set" {
    cd "$TEST_TEMP_DIR"
    unset NO_COLOR
    run make test-red
    assert_success
    [[ "$output" == *$'\033['* ]]
}

@test "colors: disabled when NO_COLOR is set" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-red
    assert_success
    [[ "$output" != *$'\033['* ]]
    assert_output "red"
}

@test "colors: print_info outputs [INFO]" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-print-info
    assert_success
    assert_output "[INFO] Test message"
}

@test "colors: print_success outputs [OK]" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-print-success
    assert_success
    assert_output "[OK] Success"
}

@test "colors: print_warning outputs [WARN]" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-print-warning
    assert_success
    assert_output "[WARN] Warning"
}

@test "colors: print_error outputs [ERROR]" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-print-error
    assert_success
    assert_output "[ERROR] Error"
}

@test "colors: print_step outputs step format" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-print-step
    assert_success
    assert_output "[1/3] Step"
}

@test "colors: print_header outputs title" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-print-header
    assert_success

    expected=$'\nTitle\n====='
    assert_output "$expected"
}

@test "colors: print_status outputs custom status" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-print-status
    assert_success
    assert_output "[CUSTOM] Status message"
}

@test "colors: NO_COLOR with any value disables colors" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=true
    run make test-red
    assert_success
    [[ "$output" != *$'\033['* ]]
}

@test "colors: multiple color variables work" {
    cd "$TEST_TEMP_DIR"
    unset NO_COLOR
    run make test-green
    assert_success
    [[ "$output" == *$'\033[0;32m'* ]]
}

@test "colors: colors with NO_COLOR empty string still shows colors" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=""
    run make test-red
    assert_success
    [[ "$output" == *$'\033['* ]]
}
