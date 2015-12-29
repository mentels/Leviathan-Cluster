# Cluster Environment for [Leviathan](https://github.com/ivanos/leviathan_node)

It is based on [Vagrant Multi-Machine](https://docs.vagrantup.com/v2/multi-machine/)

## Configuration ##

The cluster consist of three VMs:

* `leviathan1`
    * ip: 192.169.0.101
    * guest port: 8080, host port: 8081
    * running docker containers: leviathan, cont1, cont2
* `leviathan2`
    * ip: 192.169.0.102
    * guest port: 8080, host port: 8082
    * running docker containers: leviathan, cont3, cont4
* `leviathan3`
    * ip: 192.169.0.103
    * guest port: 8080, host port: 8083
    * running docker containers: leviathan, cont5, cont6

The hosts and the containers share the same private key so that they can authenticate to each other.

## Building and Running ##

To bulid the cluster run:
`make`

To login in to a particular machine run:
`vagrant ssh leviathan1`

To get shell of one of the docker containers run:
`docker attach leviathan`

To get new shell of one of the docker containers run:
`docker exec -it leviathan bash`
