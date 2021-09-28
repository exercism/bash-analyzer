#!/bin/bash

foo() { echo bar; }
main() { echo "$(foo)"; }
main
