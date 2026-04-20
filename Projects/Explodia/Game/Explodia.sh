#!/bin/sh
printf '\033c\033]0;%s\a' Explodia
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Explodia.x86_64" "$@"
