# A GNU Makefile to run various tasks - compatibility for us old-timers.

# Note: This makefile include remake-style target comments.
# These comments before the targets start with #:
# remake --tasks to shows the targets and the comments

GIT2CL ?= admin-tools/git2cl
PYTHON ?= python3
PIP ?= pip3
RM  ?= rm

.PHONY: all build check clean inputrc develop dist doc pytest sdist test rmChangeLog

#: Default target - same as "develop"
all: develop

#: build everything needed to install
build: inputrc
	$(PYTHON) ./setup.py build

#: Set up to run from the source tree
develop: inputrc
	$(PIP) install -e .

#: Make distirbution: wheels, eggs, tarball
dist:
	./admin-tools/make-dist.sh

#: Run mathicsscript and reload on file changes to the source
runner:
	watchgod mathicsscript.__main__.main

#: Install mathicsscript
install: inputrc
	$(PYTHON) setup.py install

#: Run tests. You can set environment variable "o" for pytest options
check: inputrc
	$(PYTHON) -m pytest test $o

inputrc: mathicsscript/data/inputrc-unicode mathicsscript/data/inputrc-no-unicode

mathicsscript/data/inputrc-unicode mathicsscript/data/inputrc-no-unicode mathicsscript/data/inputrc-unicode/mma-tables.json:
	$(SHELL) ./admin-tools/make- @echo "# GNU Readline input unicode translations\n# Autogenerated from mathics_scanner.generate.rl_inputrc on $$(date)\n" > $@

# Check StructuredText long description formatting
check-rst:
	$(PYTHON) setup.py --long-description | ./rst2html.py > mathicsscript.html

#: Remove derived files
clean:
	@find . -name "*.pyc" -type f -delete
	@rm mathicsscript/inputrc-no-unicode mathicsscript/inputrc-unicode || true

#: Remove ChangeLog
rmChangeLog:
	$(RM) ChangeLog || true

#: Create source tarball
sdist: check-rst
	$(PYTHON) ./setup.py sdist

#: Create a ChangeLog from git via git log and git2cl
ChangeLog: rmChangeLog
	git log --pretty --numstat --summary | $(GIT2CL) >$@
