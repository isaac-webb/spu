#!/usr/bin/env bats

setup_file() {
    TMPDIR=$(mktemp -d)
    export TMPDIR
    export SPU_SCRIPT="$BATS_TEST_DIRNAME/spu"
    export PATH="$BATS_TEST_DIRNAME:$PATH"

    git config --global init.defaultBranch main

    # Set up a working repo and push a tag
    git init --bare "$TMPDIR/remote.git"
    git clone "$TMPDIR/remote.git" "$TMPDIR/remote_working"
    cd "$TMPDIR/remote_working"
    echo "hello" > README.md
    git add README.md
    git config user.name "testing"
    git config user.email "testing@test.com"
    git commit -m "init"
    git tag v1
    git push origin main
    git push origin v1

    # Prepare baseline and init files
    git init --bare "$TMPDIR/baseline.git"
    git clone "$TMPDIR/baseline.git" "$TMPDIR/baseline_working"
    cd "$TMPDIR/baseline_working"
    echo "baseline $TMPDIR/baseline.git" > manuals.txt
    echo "testpub $TMPDIR/remote.git" >> manuals.txt
    echo "testpub v1" > versions.txt
    git add manuals.txt versions.txt
    git config user.name "testing"
    git config user.email "testing@test.com"
    git commit -m "init baseline"
    git push origin main
    echo "$TMPDIR/baseline.git" > "$TMPDIR/init_url.txt"

    # Copy the SPU script to the temporary directory
    cp "$BATS_TEST_DIRNAME/../spu" "$TMPDIR/spu"
    chmod +x "$TMPDIR/spu"
}

teardown_file() {
    rm -rf "$TMPDIR"
}

@test "spu --init creates baseline directory" {
    cd "$TMPDIR"
    run ./spu --init
    [ "$status" -eq 0 ]
    [ -d baseline/.git ]
    [ -f baseline/manuals.txt ]
    [ -f baseline/versions.txt ]
}

@test "spu clones and checks out the correct tag" {
    cd "$TMPDIR"
    run ./spu
    [ "$status" -eq 0 ]
    [ -d pubs/testpub/.git ]
    cd pubs/testpub
    run git describe --tags --exact-match
    [ "$output" = "v1" ]
}