# Cluster Environment for [Leviathan](https://github.com/ivanos/leviathan_node)

It is based on [Vagrant Multi-Machine](https://docs.vagrantup.com/v2/multi-machine/)

To start two vms with Leviathan run:
`vagrant up`

To ssh to them run:
```shell
vagrant ssh leviathan1
vagrant ssh leviathan2
```

To start the third machine with Leviathan and log in to it run:
```shell
vagrant up leviathan3 && vagrant ssh leviathan3
```
