.PHONY: all
all: test deb

.PHONY: deb
deb:
	./build-deb.sh

.PHONY: test
test:
	./tests/debtool-test.sh
