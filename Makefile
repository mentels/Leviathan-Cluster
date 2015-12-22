.PHONY: run

all: keys id_rsa run

run:
	vagrant up

keys:
	mkdir keys

id_rsa: keys
	cd keys && ssh-keygen -t rsa -f $@
