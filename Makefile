all: keys id_rsa

keys:
	mkdir keys

id_rsa: keys
	cd keys && ssh-keygen -t rsa
