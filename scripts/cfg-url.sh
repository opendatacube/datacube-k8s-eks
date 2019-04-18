#! /usr/bin/env bash
set -e
git clone --quiet --depth=1 https://github.com/"${1}" config_repo
result=$(git --git-dir config_repo/.git rev-list --all -n 1 -- $2 |  awk -v path=$2 -v repo=$1 '{printf "https://raw.githubusercontent.com/%s/%s/%s", repo, $0, path}')
rm -rf config_repo
set +e

echo "$result"