#! /usr/bin/env bash
set -e
git clone --quiet https://github.com/"${1}" docker_hub_tag_repo
result=$(git --git-dir docker_hub_tag_repo/.git describe --tags)
rm -rf docker_hub_tag_repo
set +e

echo "$result"