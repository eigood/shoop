 #!/usr/bin/make -f
TIME=/usr/bin/time -f "%E"
ITERATIONS=100
SEQ=\$$(seq 1 $(ITERATIONS))
DEF_PREP = . ./shoop.sh
DEF_PREP_I = . ./shoop.sh; _shoop_introspect=1
SH=sh
# run_command msg, prep code, loop code
benchmark = @echo -n "$(ITERATIONS) $(1): ";$(TIME) $(SH) -c "$(2); \
	for x in $(SEQ); do $(3); done " > /dev/null

benchmark2 =

all:
	@echo This makefile is only here to run benchmarks or examples.
	@echo \"make benchmark\" or \"make example\" will do that.

test: example
example:
	@sh ./example.sh

benchmark:
	$(call benchmark2,internal variable sets                    ,\
		true,\
		FOO=$x)
	$(call benchmark2,internal variable gets                    ,\
		FOO=1,\
		echo FOO)
	$(call benchmark2,internal function calls                   ,\
		foo () { echo hi; },\
		foo)
	$(call benchmark2,shoop variable sets                       ,\
		$(DEF_PREP),\
		OBJECT . foo = 1)
	$(call benchmark2,shoop variable gets                       ,\
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
	$(call benchmark2,shoop variable sets (with introspect)     ,\
		$(DEF_PREP_I),\
		OBJECT . foo = 1)
	
clean:
	rm -f *~
