#!/bin/sh -e
# Inheritance regression test. Also sets basic methods and variables.
. ./t/testlib.sh
. ./shoop.sh

# Setting/getting variables.
ok 1 "OBJECT . counter = 1"
ok 2 "OBJECT . counter = 2"
ok hello "OBJECT . moo = hello"
ok 2 "OBJECT . counter"
ok hello "OBJECT . moo"

# Remember to keep this up-to-date
total 5
