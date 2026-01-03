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

@test "help: full output matches expected" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make help
    assert_success

    read -r -d '' expected << 'EOF' || true
Test Project v1.2.3

Usage: make [target] [VARIABLE=value]

Targets:

  Build
    build                Build the project

  Test
    test-target          Run tests

  Help
    help                 Show this help message
    version              Show version information

EOF
    assert_output "$expected"
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

    read -r -d '' expected << 'EOF' || true
Test Project v1.2.3

Usage: make [target] [VARIABLE=value]

Targets:

  Build
    build                Build the project

  Test
    test-target          Run tests

  Help
    help                 Show this help message
    version              Show version information

EOF
    assert_output "$expected"
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

    read -r -d '' expected << 'EOF' || true
File Version v2.0.0}

Usage: make [target] [VARIABLE=value]

Targets:

  Help
    help                 Show this help message
    version              Show version information

EOF
    assert_output "$expected"
}

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

    read -r -d '' expected << 'EOF' || true
Desc Test
  This is a test description
Usage: make [target] [VARIABLE=value]

Targets:

  Help
    help                 Show this help message
    version              Show version information

EOF
    assert_output "$expected"
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

    read -r -d '' expected << 'EOF' || true
Vars Test

Usage: make [target] [VARIABLE=value]

Variables:
  VAR1 - First variable

Targets:

  Help
    help                 Show this help message
    version              Show version information

EOF
    assert_output "$expected"
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

    read -r -d '' expected << 'EOF' || true
Project

Usage: make [target] [VARIABLE=value]

Targets:

  Commands
    verylongtargetname             A target with a long name

  Help
    help                           Show this help message
    version                        Show version information

EOF
    assert_output "$expected"
}

@test "help: no version displayed when empty" {
    cd "$TEST_TEMP_DIR"

    cat > Makefile << 'EOF'
HELP_PROJECT_NAME := No Version
include help.mk
EOF

    export NO_COLOR=1
    run make help
    assert_success

    read -r -d '' expected << 'EOF' || true
No Version

Usage: make [target] [VARIABLE=value]

Targets:

  Help
    help                 Show this help message
    version              Show version information

EOF
    assert_output "$expected"
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

    read -r -d '' expected << 'EOF' || true
Missing File

Usage: make [target] [VARIABLE=value]

Targets:

  Help
    help                 Show this help message
    version              Show version information

EOF
    assert_output "$expected"
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

    read -r -d '' expected << 'EOF' || true
Hidden Target

Usage: make [target] [VARIABLE=value]

Targets:
    visible              This is visible

  Help
    help                 Show this help message
    version              Show version information

EOF
    assert_output "$expected"
}
