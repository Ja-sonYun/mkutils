#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup

    cat > "$TEST_TEMP_DIR/Makefile" << 'EOF'
include utils.mk

test-args:
	@echo "ARGS: $(RUN_ARGS)"

test-red:
	@printf '$(RED)red$(RESET)\n'

test-green:
	@printf '$(GREEN)green$(RESET)\n'

test-info:
	$(call msg-info,"Test message")

test-success:
	$(call msg-success,"Success")

test-warn:
	$(call msg-warn,"Warning")

test-error:
	$(call msg-error,"Error")

test-step:
	$(call msg-step,1,3,"Step")

test-header:
	$(call msg-header,"Title")

test-status:
	$(call msg-status,CUSTOM,"Status message")

test-cmd:
	$(call msg-cmd,npm install)

test-require-path:
	$(call require-path,existing-dir,Path required)
	@echo "path ok"

test-require-path-multi:
	$(call require-path,existing-dir|existing-file.txt,Paths required)
	@echo "paths ok"

test-require-path-fail:
	$(call require-path,missing-path,Create the path first)
	@echo "unreachable"

test-require-cmd:
	$(call require-cmd,make,Install make)
	@echo "cmd ok"

test-require-cmd-fail:
	$(call require-cmd,nonexistent-command-12345,Install the command)
	@echo "unreachable"

test-require-env:
	$(call require-env,HOME,Set HOME)
	@echo "env ok"

test-require-env-fail:
	$(call require-env,MISSING_ENV_VAR_12345,Set the env var)
	@echo "unreachable"

test-require-args:
	$(call require-args,dev|prod|staging,Use: dev prod staging)
	@echo "args ok: $(FIRST_ARG)"

test-require-args-fail:
	$(call require-args,dev|prod|staging,Use: dev prod staging)
	@echo "unreachable"

test-require-ports:
	$(call require-ports,59991,Port in use)
	@echo "port ok"

test-require-ports-fail:
	$(call require-ports,$(TEST_PORT),Stop the service)
	@echo "unreachable"

test-confirm:
	$(call confirm,Continue?)
	@echo "confirm ok"

test-require-regex:
	$(call require-regex,1.2.3,^[0-9]+\.[0-9]+\.[0-9]+$$,Version must be X.Y.Z)
	@echo "regex ok"

test-require-regex-fail:
	$(call require-regex,invalid,^[0-9]+\.[0-9]+\.[0-9]+$$,Version must be X.Y.Z)
	@echo "unreachable"

test-os:
	@echo "OS_NAME=$(OS_NAME)"
	@echo "IS_MACOS=$(IS_MACOS)"
	@echo "IS_LINUX=$(IS_LINUX)"

test-timed:
	$(call timed,sleep 0.1)

test-timed-fail:
	$(call timed,false)

test-require-version:
	$(call require-version,make,3.0.0,Make 3.0+ required)
	@echo "version ok"

test-require-version-fail:
	$(call require-version,make,999.0.0,Make 999+ required)
	@echo "unreachable"

test-require-memory:
	$(call require-memory,1,At least 1MB required)
	@echo "memory ok"

test-require-memory-fail:
	$(call require-memory,999999999,Need more memory)
	@echo "unreachable"

test-require-storage:
	$(call require-storage,1,At least 1MB disk space required)
	@echo "storage ok"

test-require-storage-fail:
	$(call require-storage,999999999,Need more disk space)
	@echo "unreachable"

test-retry:
	$(call retry,3,0,true)
	@echo "retry ok"

test-retry-fail:
	$(call retry,2,0,false)
	@echo "unreachable"

test-replace:
	@echo "old" > $(TEST_FILE)
	@$(call replace,old,new,$(TEST_FILE))
	@cat $(TEST_FILE)

test-semver-patch:
	@echo "$(call semver-bump,patch,1.2.3)"

test-semver-minor:
	@echo "$(call semver-bump,minor,1.2.3)"

test-semver-major:
	@echo "$(call semver-bump,major,1.2.3)"

test-escape-dq:
	@echo '$(call escape,dq,$(TEST_INPUT))'

test-escape-sq:
	@echo "$(call escape,sq,$(TEST_INPUT))"

test-escape-backslash:
	@echo '$(call escape,backslash,$(TEST_INPUT))'

test-escape-backtick:
	@echo '$(call escape,backtick,$(TEST_INPUT))'

test-escape-combined:
	@echo '$(call escape,dq|backtick,$(TEST_INPUT))'

test-msg-cmd-complex:
	$(call msg-cmd,$(TEST_INPUT))

test-slugify:
	@echo "$(call slugify,$(TEST_INPUT))"

test-truncate:
	@echo "$(call truncate,$(TEST_INPUT),$(TEST_LENGTH))"

test-pad-left:
	@echo "$(call pad-left,$(TEST_INPUT),$(TEST_LENGTH),$(TEST_CHAR))"

test-pad-right:
	@echo "$(call pad-right,$(TEST_INPUT),$(TEST_LENGTH),$(TEST_CHAR))"

test-wait-port:
	$(call wait-for-port,localhost,$(TEST_PORT),3)
	@echo "port ready"

test-wait-port-timeout:
	$(call wait-for-port,localhost,59998,1)
	@echo "unreachable"

test-wait-url:
	$(call wait-for-url,$(TEST_URL),5)
	@echo "url ready"

test-wait-url-timeout:
	$(call wait-for-url,http://localhost:59997/nonexistent,1)
	@echo "unreachable"

.PHONY: test-args test-red test-green test-info test-success test-warn test-error
.PHONY: test-step test-header test-status test-cmd
.PHONY: test-require-path test-require-path-multi test-require-path-fail
.PHONY: test-require-cmd test-require-cmd-fail
.PHONY: test-require-env test-require-env-fail
.PHONY: test-require-args test-require-args-fail
.PHONY: test-require-ports test-require-ports-fail
.PHONY: test-confirm test-require-regex test-require-regex-fail
.PHONY: test-os test-timed test-timed-fail
.PHONY: test-require-version test-require-version-fail test-retry test-retry-fail
.PHONY: test-require-memory test-require-memory-fail test-require-storage test-require-storage-fail
.PHONY: test-replace test-semver-patch test-semver-minor test-semver-major
.PHONY: test-wait-port test-wait-port-timeout test-wait-url test-wait-url-timeout
.PHONY: test-escape-dq test-escape-sq test-escape-backslash
.PHONY: test-escape-backtick test-escape-combined test-msg-cmd-complex
.PHONY: test-slugify test-truncate test-pad-left test-pad-right
EOF

    cp "$PROJECT_ROOT/dist/utils.mk" "$TEST_TEMP_DIR/utils.mk"
    mkdir -p "$TEST_TEMP_DIR/existing-dir"
    echo "content" > "$TEST_TEMP_DIR/existing-file.txt"
}

teardown() {
    _common_teardown
}

# === Args ===
@test "args: captures arguments after --" {
    cd "$TEST_TEMP_DIR"
    run make test-args -- --verbose --debug
    assert_success
    assert_output "ARGS: --verbose --debug"
}

@test "args: empty when no arguments" {
    cd "$TEST_TEMP_DIR"
    run make test-args
    assert_success
    assert_output "ARGS: "
}

# === Colors ===
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

# === Print functions ===
@test "print: info outputs [INFO]" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-info
    assert_success
    assert_output "[INFO] Test message"
}

@test "print: success outputs [OK]" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-success
    assert_success
    assert_output "[OK] Success"
}

@test "print: warn outputs [WARN]" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-warn
    assert_success
    assert_output "[WARN] Warning"
}

@test "print: error outputs [ERROR]" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-error
    assert_success
    assert_output "[ERROR] Error"
}

@test "print: step outputs step format" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-step
    assert_success
    assert_output "[1/3] Step"
}

@test "print: header outputs title" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-header
    assert_success
    expected=$'================================================================================\n\n  Title\n\n================================================================================'
    assert_output "$expected"
}

@test "print: status outputs custom status" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-status
    assert_success
    assert_output "[CUSTOM] Status message"
}

@test "print: cmd outputs command with separator" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-cmd
    assert_success
    [[ "${lines[0]}" == '$ npm install' ]]
    [[ "${lines[1]}" == *"----"* ]]
}

# === Validation functions ===
@test "require-path: passes when path exists" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-require-path
    assert_success
    assert_output "path ok"
}

@test "require-path: passes when all paths exist" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-require-path-multi
    assert_success
    assert_output "paths ok"
}

@test "require-path: fails when path missing" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-require-path-fail
    assert_failure
    assert_line "[ERROR] Path not found: missing-path"
}

@test "require-cmd: passes when command exists" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-require-cmd
    assert_success
    assert_output "cmd ok"
}

@test "require-cmd: fails when command missing" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-require-cmd-fail
    assert_failure
    assert_line "[ERROR] Command not found: nonexistent-command-12345"
}

@test "require-env: passes when env var is set" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-require-env
    assert_success
    assert_output "env ok"
}

@test "require-env: fails when env var is unset" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    unset MISSING_ENV_VAR_12345 2>/dev/null || true
    run make test-require-env-fail
    assert_failure
    assert_line "[ERROR] Environment variable not set: MISSING_ENV_VAR_12345"
}

@test "require-args: passes when arg is valid" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-require-args -- dev
    assert_success
    assert_output "args ok: dev"
}

@test "require-args: fails when arg is invalid" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-require-args-fail -- invalid
    assert_failure
    assert_line "[ERROR] Invalid argument: invalid (allowed: dev prod staging)"
}

@test "require-ports: passes when port is available" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-require-ports
    assert_success
    assert_output "port ok"
}

@test "require-ports: fails when port is in use" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    nc -l 59995 &
    NC_PID=$!
    sleep 0.1
    run make test-require-ports-fail TEST_PORT=59995
    kill $NC_PID 2>/dev/null || true
    assert_failure
    [[ "${lines[0]}" == *"Port already in use: 59995"* ]]
}

@test "confirm: passes when user types y" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run bash -c 'echo y | make test-confirm'
    assert_success
    [[ "$output" == *"confirm ok"* ]]
}

@test "confirm: fails when user types n" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run bash -c 'echo n | make test-confirm'
    assert_failure
    [[ "$output" == *"Aborted."* ]]
}

@test "require-regex: passes when value matches" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-require-regex
    assert_success
    assert_output "regex ok"
}

@test "require-regex: fails when value does not match" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-require-regex-fail
    assert_failure
    [[ "$output" == *"Validation failed: invalid"* ]]
}

# === Inputs (Python-based, non-TTY fallback) ===
@test "inputs: select non-tty returns default" {
    cd "$TEST_TEMP_DIR"
    cat >> Makefile << 'EOF'
.PHONY: test-select
test-select:
	@echo $(shell $(call select,dev|staging|prod,Select env,staging))
EOF
    run bash -c 'make test-select < /dev/null'
    assert_success
    [[ "$output" == "staging" ]]
}

@test "inputs: select non-tty returns first when no default" {
    cd "$TEST_TEMP_DIR"
    cat >> Makefile << 'EOF'
.PHONY: test-select-nodefault
test-select-nodefault:
	@echo $(shell $(call select,dev|staging|prod,Select env,))
EOF
    run bash -c 'make test-select-nodefault < /dev/null'
    assert_success
    [[ "$output" == "dev" ]]
}

@test "inputs: input non-tty returns default" {
    cd "$TEST_TEMP_DIR"
    cat >> Makefile << 'EOF'
.PHONY: test-input
test-input:
	@echo $(shell $(call input,Enter version,1.0.0))
EOF
    run bash -c 'make test-input < /dev/null'
    assert_success
    [[ "$output" == "1.0.0" ]]
}

@test "inputs: select-multi non-tty returns defaults" {
    cd "$TEST_TEMP_DIR"
    cat >> Makefile << 'EOF'
.PHONY: test-select-multi
test-select-multi:
	@for i in $(shell $(call select-multi,base|dev|prod,Select sources,base|dev)); do echo $$i; done
EOF
    run bash -c 'make test-select-multi < /dev/null'
    assert_success
    assert_line "base"
    assert_line "dev"
}

@test "inputs: select-multi non-tty returns empty when no defaults" {
    cd "$TEST_TEMP_DIR"
    cat >> Makefile << 'EOF'
.PHONY: test-select-multi-empty
test-select-multi-empty:
	@result="$(shell $(call select-multi,base|dev|prod,Select sources,))"; \
	if [ -z "$$result" ]; then echo "empty"; else echo "$$result"; fi
EOF
    run bash -c 'make test-select-multi-empty < /dev/null'
    assert_success
    assert_output "empty"
}

# === Deps ===
@test "deps: deps-target installs when dir missing" {
    cd "$TEST_TEMP_DIR"
    echo '{"name": "test"}' > package.json
    echo '{"lockfileVersion": 1}' > package-lock.json
    cat >> Makefile << 'EOF'

$(eval $(call deps-target,test-deps,echo "install",package.json,package-lock.json,node_modules))
EOF
    export NO_COLOR=1
    run make test-deps
    assert_success
    [[ "$output" == *"Installing dependencies"* ]]
    [ -f "$TEST_TEMP_DIR/node_modules/.installed" ]
}

@test "deps: deps-target skips when up to date" {
    cd "$TEST_TEMP_DIR"
    echo '{"name": "test"}' > package.json
    echo '{"lockfileVersion": 1}' > package-lock.json
    cat >> Makefile << 'EOF'

$(eval $(call deps-target,test-deps2,echo "install",package.json,package-lock.json,node_modules2))
EOF
    mkdir -p node_modules2
    touch node_modules2/.installed
    export NO_COLOR=1
    run make test-deps2
    assert_success
    [[ "$output" == *"up to date"* ]]
}

# === Help ===
@test "help: displays project name and targets" {
    cd "$TEST_TEMP_DIR"
    cat > Makefile << 'EOF'
include utils.mk
HELP_PROJECT_NAME := Test Project
HELP_VERSION := 1.0.0

##@ Build
build: ## Build the project
	@echo "Building..."
EOF
    export NO_COLOR=1
    run make help
    assert_success
    [[ "$output" == *"Test Project"* ]]
    [[ "$output" == *"v1.0.0"* ]]
    [[ "$output" == *"build"* ]]
    [[ "$output" == *"Build the project"* ]]
}

@test "help: version target works" {
    cd "$TEST_TEMP_DIR"
    cat > Makefile << 'EOF'
include utils.mk
HELP_PROJECT_NAME := Test Project
HELP_VERSION := 2.0.0
EOF
    run make version
    assert_success
    assert_output "Test Project 2.0.0"
}

# === OS Detection ===
@test "os: OS_NAME is set" {
    cd "$TEST_TEMP_DIR"
    run make test-os
    assert_success
    [[ "$output" == *"OS_NAME="* ]]
    # Should be Darwin or Linux
    [[ "$output" == *"Darwin"* ]] || [[ "$output" == *"Linux"* ]]
}

@test "os: IS_MACOS or IS_LINUX is set" {
    cd "$TEST_TEMP_DIR"
    run make test-os
    assert_success
    # One of them should be non-empty
    [[ "$output" == *"IS_MACOS=Darwin"* ]] || [[ "$output" == *"IS_LINUX=Linux"* ]]
}

# === Timed ===
@test "timed: outputs elapsed time on success" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-timed
    assert_success
    [[ "$output" == *"[OK] Done in"* ]]
    [[ "$output" == *"s"* ]]
}

@test "timed: outputs failure message on error" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-timed-fail
    assert_failure
    [[ "$output" == *"[FAIL] Failed in"* ]]
}

# === Require-version ===
@test "require-version: passes when version is sufficient" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-require-version
    assert_success
    assert_output "version ok"
}

@test "require-version: fails when version is insufficient" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-require-version-fail
    assert_failure
    [[ "$output" == *"version"* ]]
}

# === Retry ===
@test "retry: succeeds on first try" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-retry
    assert_success
    assert_output "retry ok"
}

@test "retry: fails after max attempts" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-retry-fail
    assert_failure
    [[ "$output" == *"Failed after"* ]]
}

# === Replace ===
@test "replace: replaces text in file" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-replace TEST_FILE="$TEST_TEMP_DIR/replace-test.txt"
    assert_success
    assert_output "new"
}

# === Semver ===
@test "semver-bump: patch increments patch version" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-semver-patch
    assert_success
    assert_output "1.2.4"
}

@test "semver-bump: minor increments minor and resets patch" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-semver-minor
    assert_success
    assert_output "1.3.0"
}

@test "semver-bump: major increments major and resets others" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-semver-major
    assert_success
    assert_output "2.0.0"
}

# === Wait-for-port ===
@test "wait-for-port: succeeds when port is open" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    nc -l 59996 &
    NC_PID=$!
    sleep 0.1
    run make test-wait-port TEST_PORT=59996
    kill $NC_PID 2>/dev/null || true
    assert_success
    [[ "$output" == *"port ready"* ]]
}

@test "wait-for-port: fails on timeout" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-wait-port-timeout
    assert_failure
    [[ "$output" == *"Timeout"* ]]
}

# === Wait-for-url ===
@test "wait-for-url: succeeds with valid URL" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-wait-url TEST_URL="https://httpbin.org/get"
    assert_success
    [[ "$output" == *"url ready"* ]]
}

@test "wait-for-url: fails on timeout" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-wait-url-timeout
    assert_failure
    [[ "$output" == *"Timeout"* ]]
}

# === Escape ===
@test "escape: dq escapes double quotes" {
    cd "$TEST_TEMP_DIR"
    run make test-escape-dq TEST_INPUT='hello "world"'
    assert_success
    [[ "$output" == 'hello \"world\"' ]]
}

@test "escape: sq escapes single quotes" {
    cd "$TEST_TEMP_DIR"
    run make test-escape-sq TEST_INPUT="it's working"
    assert_success
    [[ "$output" == "it'\\''s working" ]]
}

@test "escape: backslash escapes backslashes" {
    cd "$TEST_TEMP_DIR"
    run make test-escape-backslash TEST_INPUT='C:\Users\name'
    assert_success
    [[ "$output" == 'C:\\Users\\name' ]]
}

@test "escape: backtick escapes backticks" {
    cd "$TEST_TEMP_DIR"
    run make test-escape-backtick TEST_INPUT='echo `date`'
    assert_success
    [[ "$output" == 'echo \`date\`' ]]
}

@test "escape: combined options work together" {
    cd "$TEST_TEMP_DIR"
    run make test-escape-combined 'TEST_INPUT=cmd -var="value" `date`'
    assert_success
    [[ "$output" == 'cmd -var=\"value\" \`date\`' ]]
}

@test "msg-cmd: handles complex commands with quotes" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-msg-cmd-complex TEST_INPUT='packer build -var="image_type=base" -var="create_box=true"'
    assert_success
    [[ "${lines[0]}" == '$ packer build -var="image_type=base" -var="create_box=true"' ]]
}

# === String ===
@test "slugify: converts to lowercase and replaces spaces with dashes" {
    cd "$TEST_TEMP_DIR"
    run make test-slugify TEST_INPUT='Hello World'
    assert_success
    assert_output "hello-world"
}

@test "slugify: removes special characters" {
    cd "$TEST_TEMP_DIR"
    run make test-slugify TEST_INPUT='Hello World! 123'
    assert_success
    assert_output "hello-world-123"
}

@test "slugify: handles multiple spaces and special chars" {
    cd "$TEST_TEMP_DIR"
    run make test-slugify TEST_INPUT='  My  Project!!  '
    assert_success
    assert_output "my-project"
}

@test "truncate: truncates string to specified length" {
    cd "$TEST_TEMP_DIR"
    run make test-truncate TEST_INPUT='Hello World' TEST_LENGTH=5
    assert_success
    assert_output "Hello"
}

@test "truncate: returns full string if shorter than length" {
    cd "$TEST_TEMP_DIR"
    run make test-truncate TEST_INPUT='Hi' TEST_LENGTH=10
    assert_success
    assert_output "Hi"
}

@test "pad-left: pads string to specified length" {
    cd "$TEST_TEMP_DIR"
    run make test-pad-left TEST_INPUT='42' TEST_LENGTH=5 TEST_CHAR=0
    assert_success
    assert_output "00042"
}

@test "pad-left: no padding if string is already long enough" {
    cd "$TEST_TEMP_DIR"
    run make test-pad-left TEST_INPUT='12345' TEST_LENGTH=5 TEST_CHAR=0
    assert_success
    assert_output "12345"
}

@test "pad-right: pads string to specified length" {
    cd "$TEST_TEMP_DIR"
    run make test-pad-right TEST_INPUT='42' TEST_LENGTH=5 TEST_CHAR=0
    assert_success
    assert_output "42000"
}

@test "pad-right: no padding if string is already long enough" {
    cd "$TEST_TEMP_DIR"
    run make test-pad-right TEST_INPUT='12345' TEST_LENGTH=5 TEST_CHAR=0
    assert_success
    assert_output "12345"
}

# === Require-memory ===
@test "require-memory: passes when enough memory" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-require-memory
    assert_success
    assert_output "memory ok"
}

@test "require-memory: fails when insufficient memory" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-require-memory-fail
    assert_failure
    [[ "$output" == *"Insufficient memory"* ]]
}

# === Require-storage ===
@test "require-storage: passes when enough disk space" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-require-storage
    assert_success
    assert_output "storage ok"
}

@test "require-storage: fails when insufficient disk space" {
    cd "$TEST_TEMP_DIR"
    export NO_COLOR=1
    run make test-require-storage-fail
    assert_failure
    [[ "$output" == *"Insufficient disk space"* ]]
}
