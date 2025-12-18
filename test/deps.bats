#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup

    echo '{"name": "test"}' > "$TEST_TEMP_DIR/package.json"
    echo '{"lockfileVersion": 1}' > "$TEST_TEMP_DIR/package-lock.json"

    cat > "$TEST_TEMP_DIR/Makefile" << 'EOF'
include deps.mk

$(eval $(call create-deps-target,\
    test-deps,echo "install",package.json,package-lock.json,node_modules,Test))

$(eval $(call create-deps-target-with-hash,\
    test-hash,echo "install-hash",package.json,package-lock.json,.deps,Test hash))

.PHONY: test-deps test-hash
EOF

    cp "$PROJECT_ROOT/deps.mk" "$TEST_TEMP_DIR/"
}

teardown() {
    _common_teardown
}

@test "deps: installs when dir missing" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-deps
    assert_success
    assert_output --partial "install"
    [ -f "$TEST_TEMP_DIR/node_modules/.installed" ]
}

@test "deps: skips when up to date" {
    cd "$TEST_TEMP_DIR"
    mkdir -p node_modules
    touch node_modules/.installed
    export NO_COLOR=1
    run make test-deps
    assert_success
    assert_output --partial "up to date"
}

@test "deps: force always installs" {
    cd "$TEST_TEMP_DIR"
    mkdir -p node_modules
    touch node_modules/.installed
    export NO_COLOR=1
    run make test-deps-force
    assert_success
    assert_output --partial "Force"
}

@test "deps: clean removes directory" {
    cd "$TEST_TEMP_DIR"
    mkdir -p node_modules
    export NO_COLOR=1
    run make test-deps-clean
    assert_success
    [ ! -d "$TEST_TEMP_DIR/node_modules" ]
}

@test "deps-hash: creates hash file" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-hash
    assert_success
    [ -f "$TEST_TEMP_DIR/.deps/.deps-hash" ]
}

@test "deps-hash: check detects up to date" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    make test-hash
    run make test-hash-check
    assert_success
    assert_output --partial "up to date"
}

@test "deps-hash: check detects outdated" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    make test-hash
    echo '{"name": "modified"}' > "$TEST_TEMP_DIR/package.json"
    run make test-hash-check
    assert_success
    assert_output --partial "need updating"
}

# Edge cases - file modification detection

@test "deps: reinstalls when package file is newer" {
    cd "$TEST_TEMP_DIR"
    mkdir -p node_modules
    touch node_modules/.installed
    sleep 1
    touch package.json  # Make package.json newer
    export NO_COLOR=1
    run make test-deps
    assert_success
    assert_output --partial "install"
}

@test "deps: reinstalls when lock file is newer" {
    cd "$TEST_TEMP_DIR"
    mkdir -p node_modules
    touch node_modules/.installed
    sleep 1
    touch package-lock.json  # Make lock file newer
    export NO_COLOR=1
    run make test-deps
    assert_success
    assert_output --partial "install"
}

# Hash version additional targets

@test "deps-hash: force reinstalls" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    make test-hash
    run make test-hash-force
    assert_success
    assert_output --partial "Force"
}

@test "deps-hash: clean removes directory" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    make test-hash
    [ -d "$TEST_TEMP_DIR/.deps" ]
    run make test-hash-clean
    assert_success
    [ ! -d "$TEST_TEMP_DIR/.deps" ]
}

# Edge cases - lock file modification

@test "deps-hash: detects lock file change" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    make test-hash
    echo '{"lockfileVersion": 2}' > "$TEST_TEMP_DIR/package-lock.json"
    run make test-hash-check
    assert_success
    assert_output --partial "need updating"
}
