.PHONY: run vagrant-plugins

all: keys id_rsa vagrant-plugings run

run:
	vagrant up

keys:
	mkdir keys

id_rsa: keys
	cd keys && ssh-keygen -t rsa -f $@

vagrant-plugins:
	vagrant plugin install vagrant-hostmanager
	vagrant plugin install vagrant-git
