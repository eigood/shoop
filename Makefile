 #!/usr/bin/make -f
TIME=/usr/bin/time -f "%E"
ITERATIONS=10000
SEQ=\$$(seq 1 $(ITERATIONS))
DEF_PREP = . shoop.sh
# run_command msg, prep code, loop code
run_command = @echo -n "$(1): $(ITERATIONS) in ";$(TIME) sh -c "$(2); \
	for x in $(SEQ); do $(3); done " > /dev/null

benchmark:
	$(call run_command, Variable sets , $(DEF_PREP) , \
		BASE . foo = 1)
	$(call run_command, Variable gets , $(DEF_PREP); BASE . foo = 1 , \
		BASE . foo)
	$(call run_command, Method calls  , $(DEF_PREP); BASE . foo : echo hi , \
		BASE . foo)
