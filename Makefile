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
	also_inherit.sh\

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
TOPDIR=.

strip_comment_space = $(TOPDIR)/utils/shell-stripper
tinstall = $(CURDIR)/tmp-install

all:
	echo This makefile is only here to run benchmarks or examples,
	echo or install shoop, or do regression tests.
	echo \	make benchmark
	echo \	make example
	echo \	make install
	echo \	make test

test:
	$(MAKE) install prefix=$(tinstall)
	cd $(tinstall); SHOOPPATH=$(tinstall)$(moddir)\
			SHOOPMOD=$(tinstall)$(moddir)\
			SHOOPSH=$(tinstall)$(bindir)/shoop.sh\
			$(CURDIR)/t/regress\
			$(CURDIR)/t/*.sh\

example:
	sh ./example.sh

benchmark:
	$(MAKE) install prefix=$(tinstall)
	cd $(tinstall); SHOOPPATH=$(tinstall)$(moddir)\
			SHOOPMOD=$(tinstall)$(moddir)\
			SHOOPSH=$(tinstall)$(bindir)/shoop.sh\
			$(CURDIR)/t/benchmark\
			$(CURDIR)/t/benchmark.bm\
			"$(bscr)"

clean:
	echo Cleaning
	rm -f *~ .#* ChangeLog
	rm -rf $(tinstall)

install: installshare installbins installdocs installexamples

installshare	: $(patsubst %, $(prefix)$(moddir)/%,$(MODULES))
installbins	: $(patsubst %, $(prefix)$(bindir)/%,$(BINS))
installdocs	: $(patsubst %, $(prefix)$(docdir)/%,$(DOCS))
installexamples	: $(patsubst %, $(prefix)$(empdir)/%,$(EXAMPLES))
installdirs	: $(patsubst %,$(prefix)%,$(DIRS))

installshowconfig:
	echo "prefix is: $(prefix)"
	echo "bindir is: $(bindir)"
	echo "moddir is: $(moddir)"
	echo

$(patsubst %, $(prefix)$(moddir)/%,$(MODULES))	: msg=module
$(patsubst %, $(prefix)$(bindir)/%,$(BINS))	: msg=binary
$(patsubst %, $(prefix)$(docdir)/%,$(DOCS))	: msg=doc
$(patsubst %, $(prefix)$(empdir)/%,$(EXAMPLES))	: msg=examples
$(patsubst %, $(prefix)$(moddir)/%,$(MODULES))	: thisdir=moddir
$(patsubst %, $(prefix)$(bindir)/%,$(BINS))	: thisdir=bindir
$(patsubst %, $(prefix)$(docdir)/%,$(DOCS))	: thisdir=docdir
$(patsubst %, $(prefix)$(empdir)/%,$(EXAMPLES))	: thisdir=empdir


inst_msg = echo Installing $(msg) from $< to $$\(prefix\)$$\($(thisdir)\)/$<.

strip_comment_space = $(TOPDIR)/utils/shell-stripper

$(patsubst %, $(prefix)$(moddir)/%,$(MODULES)): $(prefix)$(moddir)/%: % $(prefix)$(moddir)
	$(inst_msg)
	$(strip_comment_space) < $< > $@

$(patsubst %, $(prefix)$(bindir)/%,$(BINS)): $(prefix)$(bindir)/%: % $(prefix)$(bindir)
	$(inst_msg)
	$(strip_comment_space) < $< > $@
	chmod +x $@

$(patsubst %, $(prefix)$(docdir)/%,$(DOCS)): $(prefix)$(docdir)/%: % $(prefix)$(docdir)
	$(inst_msg)
	install -m 644 $< $@

$(patsubst %, $(prefix)$(empdir)/%,$(EXAMPLES)): $(prefix)$(empdir)/%: % $(prefix)$(empdir)
	$(inst_msg)
	install -m 644 $< $@

$(patsubst %,$(prefix)%,$(DIRS)): $(prefix)%:
	echo Making dir $$\(prefix\)$*
	mkdir -p $@

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
			printf "%s:%s\"\n", A[1], A[2]\
			}\
	' AUTHORS)
#endef

ChangeLog:
	echo $(NAMES)
	rcs2log $(NAMES) > $@

ifndef NOISY
.SILENT:
endif
