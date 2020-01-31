#!/bin/bash

set -eux

_main() {
    _switch_to_repository

    if _git_is_dirty; then

        _setup_git

        _switch_to_branch

        _add_files

        _local_commit

        _push_to_github
    else
        echo "Working tree clean. Nothing to commit."
    fi
}


_switch_to_repository() {
    echo "INPUT_REPOSITORY value: $INPUT_REPOSITORY";
    cd $INPUT_REPOSITORY
}

_git_is_dirty() {
    [[ -n "$(git status -s)" ]]
}

# Set up .netrc file with GitHub credentials
_setup_git ( ) {
    git remote set-url origin https://${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git
}

_switch_to_branch() {
    echo "INPUT_BRANCH value: $INPUT_BRANCH";

    # Switch to branch from current Workflow run
    git checkout $INPUT_BRANCH
}

_add_files() {
    echo "INPUT_FILE_PATTERN: ${INPUT_FILE_PATTERN}"
    git add "${INPUT_FILE_PATTERN}"
}

_local_commit() {
    echo "INPUT_COMMIT_OPTIONS: ${INPUT_COMMIT_OPTIONS}"
    git commit -m "$INPUT_COMMIT_MESSAGE" --author="$GITHUB_ACTOR <$GITHUB_ACTOR@users.noreply.github.com>" ${INPUT_COMMIT_OPTIONS:+"$INPUT_COMMIT_OPTIONS"}
}

_push_to_github() {
    git push --set-upstream origin "HEAD:$INPUT_BRANCH"
}

_main
