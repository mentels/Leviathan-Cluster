Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2
  end
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.ssh.forward_agent = true
  config.vm.synced_folder '.', '/vagrant', nfs: true
  config.vm.boot_timeout = 60
  
  config.vm.provision "docker" do |d|
    d.version =  "1.9.0"
    d.pull_images "ivanos/leviathan:rel-0.8.1"
  end
  
  config.vm.define "leviathan1" do |lev1|
    lev1.vm.hostname = "leviathan1"
    lev1.vm.network :forwarded_port, guest: 22, host: 2201, id: "ssh"
    lev1.vm.network :forwarded_port, guest: 8080, host: 8081
    lev1.vm.network :private_network, ip: "192.169.0.101"
  end
  
  config.vm.define "leviathan2" do |lev2|
    lev2.vm.hostname = "leviathan2"
    lev2.vm.network :forwarded_port, guest: 22, host: 2202, id: "ssh"
    lev2.vm.network :forwarded_port, guest: 8080, host: 8082
    lev2.vm.network :private_network, ip: "192.169.0.102"
  end
  
  config.vm.define "leviathan3", autostart: false do |lev3|
    lev3.vm.hostname = "leviathan3"
    lev3.vm.network :forwarded_port, guest: 22, host: 2203, id: "ssh"
    lev3.vm.network :forwarded_port, guest: 8080, host: 8083
    lev3.vm.network :private_network, ip: "192.169.0.103"
  end
  
  
end
