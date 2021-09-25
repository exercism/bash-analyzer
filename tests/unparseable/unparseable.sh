#!/bin/bash

main () {
    echo unclosed body

    # shellcheck can't find next error due to unparseable script
    date ||   # missing next command
