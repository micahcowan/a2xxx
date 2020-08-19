.PHONY: all

PROGRAMS = xxx
PROGRAMS_od = $(patsubst %,%.od,$(PROGRAMS))
PROGRAMS_add = $(patsubst %,%.add,$(PROGRAMS))
all: $(PROGRAMS_add)

loadloc=0x$(shell cat $(basename $1).s | sed -n 's/^[ 	]*\.[Oo][Rr][Gg][ 	]*\$$\([0-9A-Fa-f]*\).*/\1/p')

.SECONDARY:

%.add: %.od XXX.dsk
	dos33 -y -a $(call loadloc,$@) XXX.dsk BSAVE $(basename $@).raw $(shell echo $(basename $@) | tr '[:lower:]' '[:upper:]')
	touch $@

XXX.dsk: empty.dsk HELLO Makefile
	cp empty.dsk $@
	dos33 -y $@ SAVE A HELLO

HELLO: hello.bas
	tokenize_asoft < $< > $@ || { rm $@; exit 1; }

%.od:
%.od: %.raw
	od -t u1 $< >| $@

%.raw: %.o
	ld65 -t none -o $@ $^

%.o %.list: %.s #include.inc
	ca65 --listing $(basename $@).list $(basename $@).s

.PHONY: clean
clean:
	rm -f *.add *.o *.list *.od *.raw fnord.dsk
