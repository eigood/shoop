 #!/usr/bin/make -f
TIME=/usr/bin/time -f "%E"
ITERATIONS=100
SEQ=\$$(seq 1 $(ITERATIONS))
DEF_PREP = . ./shoop.sh
SH=sh
# run_command msg, prep code, loop code
benchmark = @echo -n "$(ITERATIONS) $(1): ";$(TIME) $(SH) -c "$(2); \
	for x in $(SEQ); do $(3); done " > /dev/null

nobenchmark2 =

all:
	@echo This makefile is only here to run benchmarks or examples.
	@echo \"make benchmark\" or \"make example\" will do that.

test: example
example:
	@sh ./example.sh

benchmark:
	$(call nobenchmark,internal variable sets                    ,\
		true,\
		FOO=$x)
	$(call nobenchmark,internal variable gets                    ,\
		FOO=1,\
		echo FOO)
	$(call nobenchmark,internal function calls                   ,\
		foo () { echo hi; },\
		foo)
	$(call nobenchmark,shoop variable sets                       ,\
		$(DEF_PREP),\
		OBJECT . foo = 1)
	$(call benchmark,shoop variable gets                       ,\
		$(DEF_PREP); OBJECT . foo = $x,\
		OBJECT . foo)
	$(call benchmark,shoop method calls                        ,\
		$(DEF_PREP); OBJECT . foo : echo hi,\
		OBJECT . foo)
	$(call benchmark,shoop resolver method calls               ,\
		$(DEF_PREP); OBJECT . foo  : echo hi; OBJECT . new BAR,\
		BAR . foo)
	$(call benchmark,shoop multi-level resolver method calls   ,\
		$(DEF_PREP); OBJECT . foo  : echo hi; OBJECT . new BAR; BAR . new BLAH,\
		BLAH . foo)
	$(call nobenchmark,shoop variable sets (with introspect)     ,\
		$(DEF_PREP); _shoop_introspect=1,\
		OBJECT . foo = 1)
	
clean:
	rm -f *~
