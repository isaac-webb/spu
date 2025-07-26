#!/usr/bin/env bats

setup() {
    TMPDIR=$(mktemp -d)
    cp ./spu "$TMPDIR"
    cd "$TMPDIR"
    touch init_url.txt
    echo "https://example.com/repo.git" > init_url.txt
    mkdir baseline
    touch baseline/manuals.txt
    touch baseline/versions.txt
}

teardown() {
    rm -rf "$TMPDIR"
}

@test "Fails if not run as ./spu" {
    run bash spu
    [ "$status" -eq 1 ]
    [[ "$output" == *"Please run SPU from the root"* ]]
}

@test "Fails if git is not installed" {
    PATH=/usr/local/bin run ./spu
    [ "$status" -eq 1 ]
    [[ "$output" == *"git is required but not installed."* ]]
}

@test "Shows usage on invalid option" {
    run ./spu --not-an-option
    [ "$status" -eq 1 ]
    [[ "$output" == *"Usage:"* ]]
}

@test "Fails if manuals file is missing" {
    rm baseline/manuals.txt
    run ./spu
    [ "$status" -eq 1 ]
    [[ "$output" == *"Manuals file not found"* ]]
}

@test "Fails if versions file is missing" {
    rm baseline/versions.txt
    run ./spu
    [ "$status" -eq 1 ]
    [[ "$output" == *"Versions file not found"* ]]
}

# @test "Displays update message for --update-spu" {
#     git init .
#     git checkout -b main
#     run ./spu --update-spu
#     [ "$status" -eq 0 ]
#     [[ "$output" == *"Pulling SPU from remote repository..."* ]]
# }

@test "Displays init error if baseline exists" {
    run ./spu --init
    [ "$status" -eq 1 ]
    [[ "$output" == *"baseline directory already exists"* ]]
}

@test "Displays init error if init_url.txt missing" {
    rm init_url.txt
    rm -rf baseline
    run ./spu --init
    [ "$status" -eq 1 ]
    [[ "$output" == *"Init file init_url.txt does not exist"* ]]
}