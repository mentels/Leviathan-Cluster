$ssh = <<SCRIPT
SSHD_CONFIG="/etc/ssh/sshd_config"
TUNNEL="PermitTunnel yes"
cat ${SSHD_CONFIG} | grep "${TUNNEL}"  || \
echo "\n${TUNNEL}" >> ${SSHD_CONFIG} && sudo service ssh reload
SCRIPT

$keys = <<SCRIPT
cd /home/vagrant/.ssh
cp /vagrant/keys/id_rsa* .
cat id_rsa.pub >> authorized_keys
chown vagrant: id_rsa*
docker cp /vagrant/keys/id_rsa* ivanos/leviathan:multi-host-demo
SCRIPT

$ipv4_forwarding = <<SCRIPT
IP_FORWARD="net.ipv4.ip_forward=1"
SYSCTL_CONF="/etc/sysctl.conf"
sysctl -w ${IP_FORWARD}
cat ${SYSCTL_CONF} | grep ${IP_FORWARD} || echo ${IP_FORWARD} >> ${SYSCTL_CONF}
SCRIPT

$emacs = <<SCRIPT
apt-get install -y emacs24-nox
SCRIPT

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
  config.vm.synced_folder '.', '/vagrant'
  config.vm.boot_timeout = 60

  config.git.add_repo do |r|
    r.target = 'https://github.com/ivanos/dockerfiles.git'
    r.path = 'ivanos_dockerfiles'
    r.branch = 'multi-host'
    r.clone_in_host = true
  end
  
  config.vm.provision "docker" do |d|
    d.version =  "1.9.1"
    d.pull_images "ivanos/leviathan:rel-0.8.1"
    d.build_image '/vagrant/ivanos_dockerfiles/linc', args: "-t local/linc"
    d.build_image '/vagrant/ivanos_dockerfiles/leviathan', args: "-t ivanos/leviathan:multi-host-demo"
  end

  config.vm.provision "shell", inline: $ssh
  config.vm.provision "shell", inline: $keys
  config.vm.provision "shell", inline: $ipv4_forwarding
  config.vm.provision "shell", inline: $emacs
  
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
