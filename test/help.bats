#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup

    cat > "$TEST_TEMP_DIR/Makefile" << 'EOF'
include help.mk

HELP_PROJECT_NAME := Test Project
HELP_VERSION := 1.2.3

##@ Build
build: ## Build the project
	@echo "Building..."

##@ Test
test-target: ## Run tests
	@echo "Testing..."

.PHONY: build test-target
EOF

    cp "$PROJECT_ROOT/help.mk" "$TEST_TEMP_DIR/"
}

teardown() {
    _common_teardown
}

@test "help: shows project name" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make help
    assert_success
    assert_output --partial "Test Project"
}

@test "help: shows version" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make help
    assert_success
    assert_output --partial "v1.2.3"
}

@test "help: shows targets with descriptions" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make help
    assert_success
    assert_output --partial "build"
    assert_output --partial "Build the project"
}

@test "help: shows section headers" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make help
    assert_success
    assert_output --partial "Build"
    assert_output --partial "Test"
}

@test "help: version target outputs version" {
    cd "$TEST_TEMP_DIR"
    run make version
    assert_success
    assert_output "Test Project 1.2.3"
}

@test "help: default goal is help" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make
    assert_success
    assert_output --partial "Targets:"
}

@test "help: extracts version from file" {
    cd "$TEST_TEMP_DIR"
    echo '{"version": "2.0.0"}' > version.json

    cat > Makefile << 'EOF'
HELP_PROJECT_NAME := File Version
HELP_VERSION_FILE := version.json
include help.mk
EOF

    export NO_COLOR=1
    run make help
    assert_success
    assert_output --partial "v2.0.0"
}

# Missing configuration options

@test "help: HELP_DESCRIPTION displays text" {
    cd "$TEST_TEMP_DIR"

    cat > Makefile << 'EOF'
HELP_PROJECT_NAME := Desc Test
export HELP_DESCRIPTION := This is a test description
include help.mk
EOF

    export NO_COLOR=1
    run make help
    assert_success
    assert_output --partial "This is a test description"
}

@test "help: HELP_VARIABLES displays" {
    cd "$TEST_TEMP_DIR"

    cat > Makefile << 'EOF'
HELP_PROJECT_NAME := Vars Test
export HELP_VARIABLES := VAR1 - First variable
include help.mk
EOF

    export NO_COLOR=1
    run make help
    assert_success
    assert_output --partial "Variables:"
    assert_output --partial "VAR1"
}

@test "help: HELP_WIDTH changes column width" {
    cd "$TEST_TEMP_DIR"

    cat > Makefile << 'EOF'
HELP_WIDTH := 30
include help.mk

##@ Commands
verylongtargetname: ## A target with a long name
	@echo "ok"
EOF

    export NO_COLOR=1
    run make help
    assert_success
    assert_output --partial "verylongtargetname"
}

# Edge cases

@test "help: no version displayed when empty" {
    cd "$TEST_TEMP_DIR"

    cat > Makefile << 'EOF'
HELP_PROJECT_NAME := No Version
include help.mk
EOF

    export NO_COLOR=1
    run make help
    assert_success
    assert_output --partial "No Version"
    # Should not have "v" prefix without version
    refute_output --partial " v "
}

@test "help: missing version file handled gracefully" {
    cd "$TEST_TEMP_DIR"

    cat > Makefile << 'EOF'
HELP_PROJECT_NAME := Missing File
HELP_VERSION_FILE := nonexistent.json
include help.mk
EOF

    export NO_COLOR=1
    run make help
    assert_success
    # Should still work without crashing
    assert_output --partial "Missing File"
}

@test "help: target without ## not shown in help" {
    cd "$TEST_TEMP_DIR"

    cat > Makefile << 'EOF'
include help.mk
HELP_PROJECT_NAME := Hidden Target

visible: ## This is visible
	@echo "visible"

hidden:
	@echo "hidden"
EOF

    export NO_COLOR=1
    run make help
    assert_success
    assert_output --partial "visible"
    refute_output --partial "hidden"
}
