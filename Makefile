 #!/usr/bin/make -f
TIME=/usr/bin/time -f "%E"
ITERATIONS=10000
SEQ=\$$(seq 1 $(ITERATIONS))
DEF_PREP = . ./shoop.sh
SH=sh
# run_command msg, prep code, loop code
benchmark = @echo -n "$(ITERATIONS) $(1): ";$(TIME) $(SH) -c "$(2); \
	for x in $(SEQ); do $(3); done " > /dev/null

all:
	@echo This makefile is only here to run benchmarks or examples.
	@echo \"make benchmark\" or \"make example\" will do that.

test: example
example:
	@sh ./example.sh

benchmark:
	$(call benchmark,internal variable sets , true , FOO=$x)
	$(call benchmark,internal variable gets , FOO=1 , echo FOO)
	$(call benchmark,internal function calls, foo () { echo hi; } , foo)
	$(call benchmark,shoop variable sets, $(DEF_PREP) , BASE . foo = 1)
	$(call benchmark,shoop variable gets, $(DEF_PREP); BASE . foo = $x , \
		BASE . foo)
	$(call benchmark,shoop method calls , $(DEF_PREP); BASE . foo : echo hi , \
		BASE . foo)
	
