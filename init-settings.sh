#!/bin/bash

init_settings() {
    cd /root/my-defaults || return 0
    files="$(ls)"
    [ -z "$files" ] && return 0
    for file in $files; do
        ( . "./$(basename $file)" ) && rm -f "$file"
    done
    reboot
}

init_settings