#$Id: Makefile,v 1.20 2003/05/14 12:59:35 edmundd Exp $

VERSION=1.3

dist:
	rm -rf /tmp/chump-${VERSION}
	mkdir /tmp/chump-${VERSION}
	mkdir /tmp/chump-${VERSION}/extras
	mkdir /tmp/chump-${VERSION}/src
	mkdir /tmp/chump-${VERSION}/xslt
	cp MANUAL /tmp/chump-${VERSION}
	cp LICENSE /tmp/chump-${VERSION}
	cp README /tmp/chump-${VERSION}
	cp INSTALL /tmp/chump-${VERSION}
	cp VERSION /tmp/chump-${VERSION}
	cp ChangeLog /tmp/chump-${VERSION}
	cp extras/[^C]* src/*.1 /tmp/chump-${VERSION}/extras
	cp src/*.py /tmp/chump-${VERSION}/src
	cp xslt/*.xsl /tmp/chump-${VERSION}/xslt
	cp xslt/*.css /tmp/chump-${VERSION}/xslt
	cp xslt/README /tmp/chump-${VERSION}/xslt
	tar cvzfC chump-${VERSION}.tar.gz /tmp chump-${VERSION}
	rm -rf /tmp/chump-${VERSION}
