.PHONY: run vagrant-plugins

all: keys id_rsa vagrant-plugins run

run:
	./run.sh

keys:
	mkdir keys

id_rsa: keys
	cd keys && ssh-keygen -t rsa -f $@

vagrant-plugins:
	vagrant plugin install vagrant-hostmanager
	vagrant plugin install vagrant-git
