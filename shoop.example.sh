. shoop.sh
BASE . counter = 10
BASE . count : '$1 . counter = $(expr $($1 . counter) + 1)'
BASE . test = 20
BASE . count
BASE . new FOO
BASE . new BAR
BAR . parent A B C D FOO
FOO . counter
FOO . counter = 1
FOO . count
BAR . test
BASE . count

. introspect.sh
BAR . introspect
FOO . introspect resolve
BASE . introspect
