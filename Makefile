#!/usr/bin/make -f
#
# This makefile needs GNU make.
#
prefix=$(CURDIR)/debian/tmp

moddir=/usr/share/shoop/modules
bindir=/usr/bin
docdir=/usr/share/doc
mandir=/usr/share/man
empdir=$(docdir)/examples

DIRS=$(bindir) $(moddir) $(docdir) $(docdir)/examples

BINS=\
	shoop.sh\

MODULES=\
	destroy.sh\
	final.sh\
	introspect.sh\
	prettyprint.sh\
	serialize.sh\
	thread.sh\
	use.sh\

DOCS=\
	COPYING\
	CONTRIBUTING\
	MODULES\
	README\
	TODO\

EXAMPLES=\
	example.sh\

TIME=/usr/bin/time -f "%E" 
ITERATIONS=100 
SEQ=$(shell seq 1 $(ITERATIONS)) 
DEF_PREP = . ./shoop.sh

# run_command msg, prep code, loop code
benchmark = \
	@echo -n "bash: $(ITERATIONS) $(1): ";$(TIME) bash -c "$(2); \
	for x in $(SEQ); do $(3); done " > /dev/null ; \
	 echo -n "ash : $(ITERATIONS) $(1): ";$(TIME) ash -c "$(2); \
	for x in $(SEQ); do $(3); done " > /dev/null

nobenchmark =

all:
	@echo This makefile is only here to run benchmarks or examples,
	@echo or install shoop.
	@echo \	make benchmark
	@echo \	make example
	@echo \	make install

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
	$(call nobenchmark,shoop variable gets                       ,\
		$(DEF_PREP); OBJECT . foo = $x,\
		OBJECT . foo)
	$(call nobenchmark,shoop method calls                        ,\
		$(DEF_PREP); OBJECT . foo : echo hi,\
		OBJECT . foo)
	$(call nobenchmark,shoop resolver method calls               ,\
		$(DEF_PREP); OBJECT . foo  : echo hi; OBJECT . new BAR,\
		BAR . foo)
	$(call benchmark,shoop multi-level resolver method calls   ,\
		$(DEF_PREP); OBJECT . foo  : echo hi; OBJECT . new BAR; BAR . new BLAH,\
		BLAH . foo)
	$(call nobenchmark,shoop variable sets (with introspect)     ,\
		$(DEF_PREP); _shoop_introspect=1,\
		OBJECT . foo = 1)
	
clean:
	rm -f *~ .#*

install: installshare installbins installdocs installexamples

installshare	: $(patsubst %, $(prefix)$(moddir)/%,$(MODULES))
installbins	: $(patsubst %, $(prefix)$(bindir)/%,$(BINS))
installdocs	: $(patsubst %, $(prefix)$(docdir)/%,$(DOCS))
installexamples	: $(patsubst %, $(prefix)$(empdir)/%,$(EXAMPLES))
installdirs	: $(patsubst %,$(prefix)%,$(DIRS))

installshowconfig:
	@echo "prefix is: $(prefix)"
	@echo "bindir is: $(bindir)"
	@echo "moddir is: $(moddir)"
	@echo

$(patsubst %, $(prefix)$(moddir)/%,$(MODULES))	: msg=module
$(patsubst %, $(prefix)$(bindir)/%,$(BINS))	: msg=binary
$(patsubst %, $(prefix)$(docdir)/%,$(DOCS))	: msg=doc
$(patsubst %, $(prefix)$(empdir)/%,$(EXAMPLES))	: msg=examples
$(patsubst %, $(prefix)$(moddir)/%,$(MODULES))	: thisdir=moddir
$(patsubst %, $(prefix)$(bindir)/%,$(BINS))	: thisdir=bindir
$(patsubst %, $(prefix)$(docdir)/%,$(DOCS))	: thisdir=docdir
$(patsubst %, $(prefix)$(empdir)/%,$(EXAMPLES))	: thisdir=empdir


define inst_msg
	echo Installing $(msg) from $< to $$\(prefix\)$$\($(thisdir)\)/$<.
endef

$(patsubst %, $(prefix)$(moddir)/%,$(MODULES)): $(prefix)$(moddir)/%: % $(prefix)$(moddir)
	@$(inst_msg)
	@egrep -v '[ 	]*#' $< |(echo "#!/bin/sh -e";cat) > $@

$(patsubst %, $(prefix)$(docdir)/%,$(DOCS)): $(prefix)$(docdir)/%: % $(prefix)$(docdir)
	@$(inst_msg)
	@install -m 644 $< $@

$(patsubst %, $(prefix)$(empdir)/%,$(EXAMPLES)): $(prefix)$(empdir)/%: % $(prefix)$(empdir)
	@$(inst_msg)
	@install -m 644 $< $@

$(patsubst %,$(prefix)%,$(DIRS)): $(prefix)%:
	@echo Making dir $$\(prefix\)$*
	@mkdir -p $@

$(patsubst %, $(prefix)$(bindir)/%,$(BINS)): $(prefix)$(bindir)/%: % $(prefix)$(bindir)
	@$(inst_msg)
	@egrep -v '[ 	]*#' $< |(echo "#!/bin/sh -e";cat) > $@
	@chmod +x $@

.PHONY: installshowconfig installdirs installdocs installbins installshare  
