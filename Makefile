ITERATIONS=10000
SEQ=\$$(seq 1 $(ITERATIONS))

benchmark:
	@echo -n "Variable sets: $(ITERATIONS) in "
	@/usr/bin/time -f "%E" sh -c ". shoop.sh; \
		for x in $(SEQ); do BASE . foo = 1 ; done" >/dev/null
	@echo -n "Varibale gets: $(ITERATIONS) in "
	@/usr/bin/time -f "%E" sh -c ". shoop.sh; BASE . foo = 1; \
		for x in $(SEQ); do BASE . foo ; done" >/dev/null
