.PHONY: all

all:
	$(MAKE) -C src $@
	mv src/XXX.dsk .

%:
	$(MAKE) -C src $@
