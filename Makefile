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
benchmark = @
ifeq ($(NOBASH),)
benchmark += \
	echo -n "bash: $(ITERATIONS) $(1): ";$(TIME) bash -c "$(2); \
	for x in $(SEQ); do $(3); done " > /dev/null ;\

endif
ifeq ($(NOASH),)
benchmark += \
	echo -n "ash : $(ITERATIONS) $(1): ";$(TIME) ash -c "$(2); \
	for x in $(SEQ); do $(3); done " > /dev/null\

endif

all:
	@echo This makefile is only here to run benchmarks or examples,
	@echo or install shoop, or do regression tests.
	@echo \	make benchmark
	@echo \	make example
	@echo \	make install
	@echo \	make test

test:
	@t/regress t/*.sh

example:
	@sh ./example.sh


binstall = benchmark-dir
benchmark-install:
	$(MAKE) install prefix=$(binstall)
	$(MAKE) benchmark\
		SHOOPPATH="$(binstall)/$(moddir)"\
		DEF_PREP=". $(binstall)/$(bindir)/shoop.sh" 
	rm -rf $(binstall)
	
benchmark:
	$(test1)
	$(test2)
	$(test3)
	$(test4)
	$(test5)
	$(test6)
	$(test7)
	$(test8)
	$(test9)
	$(test10)
	$(test11)
	$(test12)

test1 = $(call benchmark,internal variable sets                       ,\
		true,\
		FOO=$x)

test2 = $(call benchmark,internal variable gets                       ,\
		FOO=1,\
		echo FOO)
test3 = $(call benchmark,internal function sets                       ,\
		:,\
		foo () { echo hi; })
test4 = $(call benchmark,internal function calls                      ,\
		foo () { echo hi; },\
		foo)
test5 = $(call benchmark,shoop variable sets                          ,\
		$(DEF_PREP),\
		OBJECT . foo = 1)
test6 = $(call benchmark,shoop variable gets                          ,\
		$(DEF_PREP); OBJECT . foo = $x,\
		OBJECT . foo)
test7 = $(call benchmark,shoop method sets                            ,\
		$(DEF_PREP) ,\
		OBJECT . foo : '')
test8 = $(call benchmark,shoop method calls                           ,\
		$(DEF_PREP); OBJECT . foo : 'echo hi;return',\
		OBJECT . foo)
# OBJECT . foo
#  BAR
test9 = $(call benchmark,shoop 1st-stage resolver method calls        ,\
		$(DEF_PREP); OBJECT . foo  : 'echo hi;return'; OBJECT . new BAR,\
		BAR . foo)
# OBJECT . foo
#  BAR
#   BLAH
test10 = $(call benchmark,shoop 2nd-stage resolver method calls        ,\
		$(DEF_PREP); OBJECT . foo  : 'echo hi;return'; OBJECT . new BAR; BAR . new BLAH,\
		BLAH . foo)
# OBJECT . foo
#  BAR
#   A
#  BLAH
#   A
#  A
#  BAZ
#   A
test11 = $(call benchmark,shoop multi-inheritance resolver method calls,\
		$(DEF_PREP); OBJECT . foo  : echo hi\;return; \
OBJECT . new BAR;\
OBJECT . new BLAH;\
OBJECT . new BAZ;\
BAR . new A;\
A . parent BAR BLAH OBJECT BAZ,\
		A . random 2>/dev/null || true)
test12 = $(call benchmark,shoop variable sets (with introspect)        ,\
		$(DEF_PREP); _shoop_introspect=1,\
		OBJECT . foo = 1)

clean:
	rm -f *~ .#* ChangeLog $(binstall)

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


inst_msg = echo Installing $(msg) from $< to $$\(prefix\)$$\($(thisdir)\)/$<.

strip_comment_space = egrep -v '^([	 ]*\#.*|[	 ]*)$$'
$(patsubst %, $(prefix)$(moddir)/%,$(MODULES)): $(prefix)$(moddir)/%: % $(prefix)$(moddir)
	@$(inst_msg)
	@$(strip_comment_space) $< |(echo "#!/bin/sh -e";cat) > $@

$(patsubst %, $(prefix)$(bindir)/%,$(BINS)): $(prefix)$(bindir)/%: % $(prefix)$(bindir)
	@$(inst_msg)
	@$(strip_comment_space) $< |(echo "#!/bin/sh -e";cat) > $@
	@chmod +x $@

$(patsubst %, $(prefix)$(docdir)/%,$(DOCS)): $(prefix)$(docdir)/%: % $(prefix)$(docdir)
	@$(inst_msg)
	@install -m 644 $< $@

$(patsubst %, $(prefix)$(empdir)/%,$(EXAMPLES)): $(prefix)$(empdir)/%: % $(prefix)$(empdir)
	@$(inst_msg)
	@install -m 644 $< $@

$(patsubst %,$(prefix)%,$(DIRS)): $(prefix)%:
	@echo Making dir $$\(prefix\)$*
	@mkdir -p $@


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
