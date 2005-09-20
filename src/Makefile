
.PHONY: all install

SCRIPTS=ChumpTest.py churnsaxparser.py dailychumpcmd.py \
	dailychumphttp.py dailychump.py dailychumptwist.py \
	EntityEncoder.py EntityEncoderU.py spider.py

WEB=__init__.py xmldir.py
MAN1=dailychump.1

PROGS=dailychump.sh

DESTDIR=/usr/local

all:
	@echo "nothing to do, run 'make install DESTDIR=/usr/local'"
	@echo "to install to /usr/local, etc, etc."

install:
	mkdir -p $(DESTDIR)/lib/dailychump
	for x in $(SCRIPTS); do \
		install -m 0644 $$x $(DESTDIR)/lib/dailychump/$$x \
	end
	mkdir -p $(DESTDIR)/lib/dailychump/web
	for x in $(WEB); do \
		install -m 0644 $$x $(DESTDIR)/lib/dailychump/web/$$x \
	end
	mkdir -p $(DESTDIR)/bin
	for x in $(PROGS); do \
		install -m 0755 $$x $(DESTDIR)/bin/$$x \
	end
	mkdir -p $(DESTDIR)/man/man1
	for x in $(MAN1); do \
		install -m 0644 $$x $(DESTDIR)/man/man1/$$x \
	end
