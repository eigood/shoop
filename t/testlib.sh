#!/bin/sh -e
# Regression test framework (modeled on perl's if you can't tell).

echo Beginning test of $0 ..

testfailures=0
testcount=0
ok () {
	expected=$1
	shift
	
	testcount=$(expr $testcount + 1)
	local ret=$($@) || (
		echo test $testcount returned a failure code: $?
		testfailures=$(expr $testfailures + 1)
	)
	if [ "$ret" = "$expected" ]; then
		if [ "$VERBOSE" ]; then
			echo test $testcount succeeded
		fi
	else
		echo test $testcount FAILED: expected $expected, but got $ret
		testfailures=$(expr $testfailures + 1)
	fi
}

total () {
	if [ "$1" != "$testcount" ]; then
		echo I was expecting $1 tests, but $testcount were run.
	fi
	if [ "$testfailures" != "0" ]; then
		echo $testfailures tests FAILED.
	else
		echo All tests succeeded.
	fi
}
