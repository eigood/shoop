. shoop.sh
BASE . counter = 10
BASE . count : '$1 . counter = $(expr $($1 . counter) + 1)'
BASE . count
BASE . new FOO
FOO . counter
FOO . counter = 1
FOO . count
BASE . count
