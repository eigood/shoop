#!/bin/sh -e
# Inheritance regression test. Also sets basic methods and variables.
. ./shoop.sh

# Setting/getting variables.
ok 1 "OBJECT . counter = 1"
ok 2 "OBJECT . counter = 2"
ok hello "OBJECT . moo = hello"
ok 2 "OBJECT . counter"
ok hello "OBJECT . moo"

tests 5
