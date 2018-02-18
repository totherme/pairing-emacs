#!/usr/bin/env bash

# basht macro, shellcheck fix
export T_fail

export TESTS_ONLY=1		# Tell it not to run main
. "../install"			# load the functions to test
set +euo pipefail		# basht requires +eu etc

T_get_git_repo_backs_up_and_clones() {
    local tmpdir source target sdata tdata backupdata output exit_one exit_two
    tmpdir="$(mktemp -d)"
    source="${tmpdir}/source"
    target="${tmpdir}/target"
    sdata="${source}/data"
    tdata="${target}/data"
    backupdata="${target}.backup/data"

    mkdir -p "$source"
    echo -n "first data" > "$sdata"
    git -C "$source" init > /dev/null
    git -C "$source" add "$sdata"
    git -C "$source" commit -m 'first commit' > /dev/null

    get_git_repo "$source" "$target"
    exit_one="$?"

    echo -n "second data" > "$sdata"
    git -C "$source" add "$sdata"
    git -C "$source" commit -m 'second commit' > /dev/null

    output="$(get_git_repo "$source" "$target" 2>&1)"
    exit_two="$?"

    expect_to_equal "$(cat "$tdata")" "second data" &&
	expect_to_equal "$(cat "$backupdata")" "first data" &&
	expect_to_equal "$exit_one" "0" &&
	expect_to_equal "$exit_two" "0" &&
	expect_to_contain "$output" "Found existing ${target}. Backing it up."
}

T_when_git_missing_get_git_repo_fails_helpfully() {
    local exit_code output

    output="$(PATH="" get_git_repo "doesn't" "matter" 2>&1)"
    exit_code="$?"

    expect_to_equal "$exit_code" "1" &&
	expect_to_contain "$output" "You don't seem to have git"
}

T_backup_and_remove_preserves_previous_data() {
    local tmpdir filepath
    tmpdir="$(mktemp -d)"
    filepath="${tmpdir}/file"

    echo -n "pre-existing-data" > "$filepath"
    backup_and_remove "$filepath"

    echo -n "more-existing-data" > "$filepath"
    backup_and_remove "$filepath"

    echo -n "more-existing-data-2" > "$filepath"
    backup_and_remove "$filepath"

    echo -n "more-existing-data-3" > "$filepath"
    backup_and_remove "$filepath"

    expect_file_to_be_missing "$filepath" &&
	expect_to_equal "$(cat "$filepath.backup")" "pre-existing-data" &&
	expect_to_equal "$(cat "$filepath.backup.1")" "more-existing-data" &&
	expect_to_equal "$(cat "$filepath.backup.2")" "more-existing-data-2" &&
	expect_to_equal "$(cat "$filepath.backup.3")" "more-existing-data-3"
}

T_backup_and_remove_strips_trailing_slashes() {
    local tmpdir filepath
    tmpdir="$(mktemp -d)"
    filepath="${tmpdir}/file"

    echo -n "pre-existing-data" > "$filepath"
    backup_and_remove "$filepath/"

    echo -n "more-existing-data" > "$filepath"
    backup_and_remove "$filepath///"


    expect_file_to_be_missing "$filepath" &&
	expect_to_equal "$(cat "$filepath.backup")" "pre-existing-data" &&
	expect_to_equal "$(cat "$filepath.backup.1")" "more-existing-data"
}

T_when_go_bin_missing_optionally_get_go_tools_warns() {
    local exit_code output

    output="$(PATH="" optionally_get_go_tools 2>&1)"
    exit_code="$?"
    
    expect_to_equal "$exit_code" "0" &&
	expect_to_contain "$output" "You don't seem to have go"
}

T_when_gopath_missing_optionally_get_go_tools_warns() {
    local exit_code output

    output="$(GOPATH="" optionally_get_go_tools 2>&1)"
    exit_code="$?"
    
    expect_to_equal "$exit_code" "0" &&
	expect_to_contain "$output" "You don't seem to have a \$GOPATH"
}

T_when_no_tmux_conf_exists_install_tmux_config_from_creates_one() {
    local tmpdir sourcepath exit_code
    tmpdir="$(mktemp -d)"

    sourcepath="${tmpdir}/source.conf"
    echo "source config" > "$sourcepath"

    HOME="$tmpdir" install_tmux_config_from "$sourcepath"
    exit_code="$?"

    expect_to_equal "$(cat "${tmpdir}/.tmux.conf")" "source config" &&
	expect_to_equal "$exit_code" "0"
}

T_when_tmux_conf_exists_install_tmux_config_from_backs_it_up() {
    local tmpdir sourcepath confpath output exit_code
    tmpdir="$(mktemp -d)"

    sourcepath="${tmpdir}/source.conf"
    echo "source config" > "$sourcepath"

    confpath="${tmpdir}/.tmux.conf"
    echo "previous config" > "$confpath"

    output="$(HOME="$tmpdir" install_tmux_config_from "$sourcepath" 2>&1)"
    exit_code="$?"

    expect_to_equal "$(cat "$confpath")" "source config" &&
	expect_to_equal "$(cat "${confpath}.backup")" "previous config" &&
	expect_to_equal "$exit_code" "0" &&
	expect_to_contain "$output" "Found an existing \$HOME/.tmux.conf. Backing it up."
}

expect_to_equal() {
    local actual expected diff_output diff_exit
    actual="${1:?Expected 'actual' arg in expect_to_equal}"
    expected="${2:?Expected 'expected' arg in expect_to_equal}"

    diff_output="$(diff <(echo "$actual") <(echo "$expected"))"
    diff_exit=$?

    if [[ $diff_exit != 0 ]]
    then
	echo -e "$diff_output"
	return $diff_exit
    fi
}

expect_to_contain() {
    local string pattern grep_exit
    string="${1:?Expected 'string' arg in expect_to_contain}"
    pattern="${2:?Expected 'pattern' arg in expect_to_contain}"

    echo "$string" | grep "$pattern" > /dev/null
    grep_exit=$?

    if [[ $grep_exit != 0 ]]
    then
	echo "Expected string \"$string\" to contain pattern \"$pattern\"."
	return $grep_exit
    fi
}

expect_file_to_be_missing() {
    local filepath
    filepath="${1:?Expected 'filepath' arg in expect_file_to_be_missing}"

    if [[ -e "$filepath" ]] ; then
	echo "Expected $filepath to be missing. But it exists."
	return 1
    fi
}
