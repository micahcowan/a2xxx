.PHONY: all

PROGRAMS = mixcase fnord hlspaces double leet whabat
PROGRAMS_od = $(patsubst %,%.od,$(PROGRAMS))
PROGRAMS_add = $(patsubst %,%.add,$(PROGRAMS))
all: $(PROGRAMS_add)

.SECONDARY:

%.add: %.od fnord.dsk
	dos33 -y -a 0x300 fnord.dsk BSAVE $(basename $@).raw $(shell echo $(basename $@) | tr '[:lower:]' '[:upper:]')
	touch $@

fnord.dsk: empty.dsk HELLO
	cp empty.dsk fnord.dsk
	dos33 -y fnord.dsk SAVE A HELLO

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
