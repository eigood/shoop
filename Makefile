#!/usr/bin/make -f
#
# This makefile needs GNU make.
#
TOPDIR=$(CURDIR)
prefix=$(CURDIR)/debian/shoop

moddir=/usr/share/shoop/modules
bindir=/usr/share/shoop
docdir=/usr/share/doc/shoop
mandir=/usr/share/man
empdir=$(docdir)/examples

MODULES_MSG=modules
BINS_MSG=binary
DOCS_MSG=documents
EXAMPLES_MSG=examples
MAN_MSG=man pages

DIRS=$(bindir) $(moddir) $(docdir) $(docdir)/examples

SUBDIRS=modules docs

BINS=\
	shoop.sh\

DOCS=\
	COPYING\
	TODO\
	
EXAMPLES=\
	example.sh\

PKG=shoop
PKG_VER=0.1
TOPDIR=.

tinstall = $(CURDIR)/tmp-install

all:
	echo This makefile is only here to run benchmarks or examples,
	echo or install shoop, or do regression tests.
	echo \	make benchmark
	echo \	make example
	echo \	make install
	echo \	make test

test:
	$(MAKE) installmodules installbins prefix=$(tinstall)
	cd $(tinstall); SHOOPPATH=$(tinstall)$(moddir)\
			SHOOPMOD=$(tinstall)$(moddir)\
			SHOOPSH=$(tinstall)$(bindir)/shoop.sh\
			CURDIR=$(CURDIR)\
			$(SHELL) $(CURDIR)/t/regress\
			$(CURDIR)/t/inheritance.sh\
			$(CURDIR)/t/list.sh\

www-test1:
	$(MAKE) installbins installmodules prefix=$(tinstall)
	cd $(tinstall); SHOOPPATH=$(tinstall)$(moddir)\
			SHOOPMOD=$(tinstall)$(moddir)\
			SHOOPSH=$(tinstall)$(bindir)/shoop.sh\
			CURDIR=$(CURDIR)\
			$(CURDIR)/t/benchmark\
			$(CURDIR)/t/kbu.bm\
			""

www-test2:
	$(MAKE) installbins installmodules prefix=$(tinstall)
	cd $(tinstall); SHOOPPATH=$(tinstall)$(moddir)\
			SHOOPMOD=$(tinstall)$(moddir)\
			SHOOPSH=$(tinstall)$(bindir)/shoop.sh\
			CURDIR=$(CURDIR)\
			$(CURDIR)/t/benchmark\
			$(CURDIR)/t/kbhomes.bm\
			""

example:
	$(MAKE) installbins installmodules prefix=$(tinstall)
	cd $(tinstall); SHOOPPATH=$(tinstall)$(moddir)\
			SHOOPMOD=$(tinstall)$(moddir)\
			SHOOPSH=$(tinstall)$(bindir)/shoop.sh\
			CURDIR=$(CURDIR)\
			$(CURDIR)/example.sh

benchmark:
	$(MAKE) installbins installmodules prefix=$(tinstall)
	cd $(tinstall); SHOOPPATH=$(tinstall)$(moddir)\
			SHOOPMOD=$(tinstall)$(moddir)\
			SHOOPSH=$(tinstall)$(bindir)/shoop.sh\
			CURDIR=$(CURDIR)\
			$(CURDIR)/t/benchmark\
			$(CURDIR)/t/benchmark.bm\
			"$(bscr)"

clean_dirs=$(tinstall)
clean_files=*~ .\#* ChangeLog docs/modules.pod

#
# Author only targets are below
#

cvs-build:
	rm -rf cvs-build
	$(MAKE) ChangeLog
	tar c --exclude CVS --exclude cvs-build . |\
		(mkdir -p cvs-build/$(PKG)-$(PKG_VER);cd cvs-build/$(PKG)-$(PKG_VER);tar x)

docs/modules.pod: utils/shelldoc $(MODULES)
	rm -f modules_tmp
	$(MAKE) modules_tmp
	utils/shelldoc "SHOOP Modules" $$(cat modules_tmp) > $@
	rm -f modules_tmp

docs/modules.txt: docs/modules.pod

dyndocs: www/modules.html docs/modules.txt
modules_title=SHOOP Modules

%.txt: %.pod
	pod2text < $< > $@
%.html: %.pod
	pod2html --title "$($(*F)_title)"< $< > $@

www/modules.html: docs/modules.html
	cp -a $< $@

clean_files+=www/modules.html docs/modules.txt docs/modules.html docs/modules.pod 
clean_files+=pod2html-dircache pod2html-itemcache

ChangeLog:
	utils/mkChangeLog $@

include $(TOPDIR)/Makefile.rules

.PHONY: docs/modules.pod
