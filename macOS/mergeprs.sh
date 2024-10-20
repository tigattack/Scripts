#!/usr/bin/env bash

if [[ -z "$@" ]]; then
    echo "Usage: mergeprs.sh [PR]..."
fi

for i in "$@"; do
    gh pr merge $i --repo tigattack/infrastructure -m -d
    sleep 1
done
