.PHONY: deb test

deb:
	./build-deb.sh

test:
	tests/debtool-test.sh
