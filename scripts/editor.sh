#!/usr/bin/env bash

# Check VSCODE_GIT_ASKPASS_NODE
if [ "$VSCODE_GIT_ASKPASS_NODE" ]
then
    exec "$VSCODE_GIT_ASKPASS_NODE" --wait "$@"
fi

exec nano "$@"