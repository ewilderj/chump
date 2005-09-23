
.PHONY: all install

SCRIPTS=ChumpTest.py churnsaxparser.py dailychumpcmd.py \
	dailychumphttp.py dailychump.py dailychumptwist.py \
	EntityEncoder.py EntityEncoderU.py spider.py

WEB=__init__.py xmldir.py
MAN1=dailychump.1

DESTDIR=/usr/local

all:
	@echo "nothing to do, run 'make install DESTDIR=/usr/local'"
	@echo "to install to /usr/local, etc, etc."

install:
	mkdir -p $(DESTDIR)/lib/dailychump
	for x in $(SCRIPTS); do \
		install -m 0644 $$x $(DESTDIR)/lib/dailychump/$$x; \
	done
	mkdir -p $(DESTDIR)/lib/dailychump/web
	for x in $(WEB); do \
		install -m 0644 web/$$x $(DESTDIR)/lib/dailychump/web/$$x; \
	done
	sed -e 's#@@WHERE@@#$(DESTDIR)/lib/dailychump#' < dailychump \
		> $(DESTDIR)/bin/dailychump
	chmod 0755 $(DESTDIR)/bin/dailychump
	mkdir -p $(DESTDIR)/man/man1
	for x in $(MAN1); do \
		install -m 0644 $$x $(DESTDIR)/man/man1/$$x; \
	done
