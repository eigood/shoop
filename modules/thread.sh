#!/bin/sh
#                                                                               
# Pseudothread module for shoop. These arn't real threads (no shared data),
# but they start up like threads.
#                                                                               
# GPL copyright 2000 by Adam Heath <doogie@debian.org>
OBJECT . new THREAD

THREAD . start :p '
	if [ -z "$($THIS . running)" ]; then
		$THIS . run &
		$THIS . pid = $! > /dev/null
		$THIS . running = 1 > /dev/null
	fi
'
THREAD . stop :p '
	if [ -z "$($THIS . running)" ]; then
		kill $($THIS . pid)
	fi
'
THREAD . wait :p '
	wait $($THIS . pid)
'
