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

PKG=shoop
PKG_VER=0.1

TIME=/usr/bin/time -f "%E" 
ITERATIONS=1000
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
	@echo or install shoop, or do regression tests.
	@echo \	make benchmark
	@echo \	make example
	@echo \	make install
	@echo \	make test

test:
	for f in t/*.sh; do t/regress $$f; done

example:
	@sh ./example.sh

benchmark:
	$(call benchmark,internal variable sets                    ,\
		true,\
		FOO=$x)
	$(call benchmark,internal variable gets                    ,\
		FOO=1,\
		echo FOO)
	$(call benchmark,internal function calls                   ,\
		foo () { echo hi; },\
		foo)
	$(call benchmark,shoop variable sets                       ,\
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
	$(call benchmark,shoop variable sets (with introspect)     ,\
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

.PHONY: installshowconfig installdirs installdocs installbins installshare ChangeLog

#
# Author only targets are below
#

cvs-build:
	rm -rf cvs-build
	$(MAKE) ChangeLog
	tar c --exclude CVS --exclude cvs-build . |\
		(mkdir -p cvs-build/$(PKG)-$(PKG_VER);cd cvs-build/$(PKG)-$(PKG_VER);tar x)

NAMES=$(shell\
	awk '\
	/^CVS:/{\
	sub(/^CVS:/, "");\
	printf "-u \"%s:", $$1;\
	sub($$1 " ","");\
	split($$0, A, / *[<>] */);\
	printf "%s:%s\"\n", A[1], A[2]}\
' AUTHORS)
#endef

ChangeLog:
	echo $(NAMES)
	rcs2log $(NAMES) > $@
