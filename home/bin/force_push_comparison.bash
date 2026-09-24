#!/bin/bash

# SPDX-FileCopyrightText: © 2026 hashcatHitman
#
# SPDX-License-Identifier: Apache-2.0 OR MIT

# This script is meant to help illustrate the benefit of using
# `--force-if-includes` when force pushing.
#
# To use it, create a new repository on your favorite forge (such as GitHub or
# GitLab). Make sure it has at least one commit. Clone it twice two two separate
# directories on your machine.
#
# The variables in RUN CONFIGURATION may be changed before each run of the
# program.
#
# The variables in FIXED CONFIGURATION should only need to be configured once.
#
# If a synchronization check fails, it is probably because a stash was made. You
# should inspect the stash to make sure it doesn't contain anything important,
# then drop it.

set -euo pipefail

# RUN CONFIGURATION

# Set this to "fetch" to have Alice fetch. Any other value results in no fetch.
MIGHT_BE_FETCH="fetch"

# What Alice should do before trying to force push. Accepted values:
#
# "ff-only" OR 0
#   Alice will `git pull --ff-only`. This is the default behavior of
#   `git pull` and will not work, because the histories diverge.
#
# "ff" OR 1
#   Alice will `git pull --ff`. This is documented as using `git merge` behind
#   the scenes, and leads to a history that contains A, B, A', and a merge
#   commit.
#
# "rebase" OR 2
#   Alice will `git pull --rebase`. This is documented as using `git rebase`
#   behind the scenes, and leads to a history that contains A, B, and A'.
#
# "no-rebase" OR 3
#   Alice will `git pull --no-rebase`. This is documented as using `git merge`
#   behind the scenes, and leads to a history that contains A, B, A', and a
#   merge commit.
#
# "rebase-direct" OR 4
#   Alice will `git rebase "${REMOTE}/${BRANCH}"`. This leads to a history that
#   contains A, B, and A'.
#
# "merge" OR 5
#   Alice will `git merge "${REMOTE}/${BRANCH}"`. This leads to a history that
#   contains A, B, A', and a merge commit.
#
# "rebase-interactive" OR 6
#   Alice will `git pull --rebase` and then `git rebase -i --root` to
#   intentionally drop Bob's changes. This leads to a history that contains A
#   and A'. This script is not interactive, so I simulate this with a neat
#   trick.
#
# "nothing" OR 7
#   Alice will not try to do anything before force pushing.
#
# Any other value is an error.
INTEGRATION_STRATEGY="rebase-interactive"

# What kind of force push Alice will use. Accepted values:
#
# "force" OR 0
#   Alice will `git push "${REMOTE}" --force`.
#
# "force-with-lease" OR 1
#   Alice will `git push "${REMOTE}" --force-with-lease`.
#
# "force-if-includes" OR 2
#   Alice will `git push "${REMOTE}" --force-with-lease --force-if-includes`.
#
# Any other value is an error.
FORCE_PUSH_STRATEGY="force-if-includes"

# FIXED CONFIGURATION

# The path to Alice's clone of the remote repository. Should be different than
# Bob's.
ALICE_CLONE_DIR="/tmp/forgot_to_set_ALICE_CLONE_DIR"

# The path to Bob's clone of the remote repository. Should be different than
# Alice's.
BOB_CLONE_DIR="/tmp/forgot_to_set_BOB_CLONE_DIR"

# The name of the remote.
REMOTE="origin"

# The name of the branch Alice and Bob will work on.
BRANCH="main"

# The hash of the commit that Alice and Bob should reset to before the start of
# a run to make sure they are in sync. This is should be the most recent commit
# on their working branch on the remote prior to attempting to use this script.
INITIAL_COMMIT="0000000000000000000000000000000000000000"

# COLORS
ALICE_COLOR='\033[0;31m'
BOB_COLOR='\033[0;34m'
RESET='\033[0m'

reset_alice() {
    echo -e "${ALICE_COLOR}Resetting Alice to ${INITIAL_COMMIT}...${RESET}"
    cd "${ALICE_CLONE_DIR}" || exit 1
    git add . && git stash -m "ALICE STASH" || exit 1
    git checkout "${BRANCH}" || exit 1
    git fetch || exit 1
    git pull --rebase || exit 1
    git reset --hard "${INITIAL_COMMIT}" || exit 1
    git push --force "${REMOTE}" || exit 1
}

reset_bob() {
    echo -e "${BOB_COLOR}Resetting Bob to ${INITIAL_COMMIT}...${RESET}"
    cd "${BOB_CLONE_DIR}" || exit 1
    git add . && git stash -m "BOB STASH" || exit 1
    git checkout "${BRANCH}" || exit 1
    git fetch || exit 1
    git pull --rebase || exit 1
    git reset --hard "${INITIAL_COMMIT}" || exit 1
}

check_synchronized() {
    local alice_refs
    local bob_refs

    cd "${ALICE_CLONE_DIR}" || exit 1
    alice_refs="$(git show-ref)"

    cd "${BOB_CLONE_DIR}" || exit 1
    bob_refs="$(git show-ref)"

    if [[ "${alice_refs}" != "${bob_refs}" ]]; then
        echo "MISMATCH AFTER RESET ATTEMPT:"
        echo "ALICE:"
        echo "${alice_refs}"
        echo -e "\nBOB:"
        echo "${bob_refs}"
        exit 1
    else
        return 0
    fi
}

alice_commit() {
    local alice_file="${1}"
    local commit_id="${2}"

    echo -e "${ALICE_COLOR}Alice adding commit ${commit_id}...${RESET}"
    cd "${ALICE_CLONE_DIR}" || exit 1
    echo "${alice_file}" >"${alice_file}.txt" || exit 1
    git add "${alice_file}.txt" || exit 1
    git commit -m "commit ${commit_id}: add ${alice_file}.txt" || exit 1
    git push "${REMOTE}" || exit 1
}

bob_update() {
    echo -e "${BOB_COLOR}Bob fetching and pulling...${RESET}"
    cd "${BOB_CLONE_DIR}" || exit 1
    git fetch || exit 1
    git pull || exit 1
}

bob_commit() {
    local bob_file="${1}"
    local commit_id="${2}"

    echo -e "${BOB_COLOR}Bob adding commit ${commit_id}...${RESET}"
    cd "${BOB_CLONE_DIR}" || exit 1
    echo "${bob_file}" >"${bob_file}.txt" || exit 1
    git add "${bob_file}.txt" || exit 1
    git commit -m "commit ${commit_id}: add ${bob_file}.txt" || exit 1
    git push "${REMOTE}" || exit 1
}

alice_amend() {
    local alice_file_original="${1}"
    local commit_id_original="${2}"
    local alice_file_new="${3}"
    local commit_id_new="${4}"

    echo -e "${ALICE_COLOR}Alice amending commit ${commit_id_original} to \
${commit_id_new}...${RESET}"
    cd "${ALICE_CLONE_DIR}" || exit 1
    echo "${alice_file_new}" >"${alice_file_new}.txt" || exit 1
    git add "${alice_file_new}.txt" || exit 1
    git commit --amend -m "commit ${commit_id_new}: add \
${alice_file_original}.txt and ${alice_file_new}" || exit 1
}

alice_integrate() {
    case "${INTEGRATION_STRATEGY}" in
    # Will not work because the histories diverge. This is the default mode of
    # `git pull`.
    "ff-only" | 0)
        git pull --ff-only || exit 1
        ;;
    # Uses `git merge`. Leads to A, B, A', and a merge commit.
    "ff" | 1)
        git pull --ff --no-edit || exit 1
        ;;
    # Uses `git rebase`. Leads to A, B, and A'.
    "rebase" | 2)
        git pull --rebase || exit 1
        ;;
    # Uses `git merge`. Leads to A, B, A', and a merge commit.
    "no-rebase" | 3)
        git pull --no-rebase --no-edit || exit 1
        ;;
    # Will also work, leading to A, B, and A'.
    "rebase-direct" | 4)
        git rebase "${REMOTE}/${BRANCH}" || exit 1
        ;;
    # Will also work, leading to A, B, A', and a merge commit.
    "merge" | 5)
        git merge "${REMOTE}/${BRANCH}" --no-edit || exit 1
        ;;
    # To satisfy force-if-includes, "integration" doesn't actually require that
    # you keep the changes someone else made. It just requires you explicitly
    # decide what to do about them.
    "rebase-interactive" | 6)
        local bobs_hash
        bobs_hash="$(git show-ref "${REMOTE}/${BRANCH}")"
        bobs_hash="${bobs_hash%" refs/remotes/${REMOTE}/${BRANCH}"}"
        # You can also choose to *not* have Bob's changes. For example, you can
        # do:
        git pull --rebase || exit 1
        # To get A, B, and A'. Then you could do `git rebase -i --root` and drop
        # the new commits you don't really want (simulated below, because this
        # isn't an interactive script). Then the push would work.
        git -c rebase.instructionFormat="%s%nexec if [[ \"%H\" == \
\"${bobs_hash}\" ]]; then git reset --hard HEAD^; fi" rebase --root || exit 1
        ;;
    "nothing" | 7)
        ;;
    *)
        echo "Unrecognized integration strategy ${INTEGRATION_STRATEGY}! Double\
 check your configuration!"
        exit 1
        ;;
    esac
}

alice_force_push() {
    cd "${ALICE_CLONE_DIR}" || exit 1
    case "${FORCE_PUSH_STRATEGY}" in
    "force" | 0)
        git push "${REMOTE}" --force || exit 1
        ;;

    "force-with-lease" | 1)
        git push "${REMOTE}" --force-with-lease || exit 1
        ;;

    "force-if-includes" | 2)
        git push "${REMOTE}" --force-with-lease --force-if-includes || exit 1
        ;;

    *)
        echo "Unrecognized force push strategy ${FORCE_PUSH_STRATEGY}! Double \
check your configuration!"
        exit 1
        ;;
    esac
}

alice_maybe_fetch() {
    if [[ "${MIGHT_BE_FETCH}" == "fetch" ]]; then
        cd "${ALICE_CLONE_DIR}" || exit 1
        git fetch || exit 1
    fi
}

main() {
    # Set up Alice
    reset_alice

    # Set up Bob
    reset_bob

    # Confirm that they are in sync
    check_synchronized

    # Alice adds a new commit A and pushes it
    alice_commit "alice_foo" "A"

    # Bob fetches and pulls
    bob_update

    # Confirm that they are still in sync
    check_synchronized

    # Bob adds a new commit B and pushes it
    bob_commit "bob_foo" "B"

    # Alice amends commit A, for whatever reason she has, and force pushes A'
    #
    # If Alice (or her editor) does `git fetch` at any point after Bob pushes
    # commit B but before she tries to do
    # `git push "${REMOTE}" --force-with-lease`, the push will succeed, and
    # commit B mysteriously disappears.
    #
    # If, instead, Alice was using:
    #
    # `git push "${REMOTE}" --force-with-lease --force-if-includes`
    #
    # The push would fail and warn her that the remote has been updated, and she
    # must `git pull` before she can push. Because the histories diverge,
    # `git pull` cannot fast-forward. In my experience, `git rebase` will
    # usually just work and give me what I want. If it doesn't, an interactive
    # rebase like described in `rebase-interactive` is extremely convenient for
    # cleaning up divergent histories.
    alice_maybe_fetch
    alice_amend "alice_foo" "A" "alice_bar" "A'"
    alice_integrate
    alice_force_push
}

main
