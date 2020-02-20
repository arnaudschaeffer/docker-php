#!/bin/bash

set -x

# Adapt UID & GID if needed
if [[ -n "$UID" ]] && [[ "$(id -u php)" != "$UID" ]]; then
    usermod -u ${UID} php
fi

if [[ -n "$GID" ]] && [[ "$(id -g php)" != "$GID" ]]; then
    groupmod -g ${GID} php
fi