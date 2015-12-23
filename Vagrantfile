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
docker cp /vagrant/keys/id_rsa leviathan:/root/.ssh/id_rsa
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

INLINES = [$ssh, $keys, $ipv4_forwarding, $emacs]

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
  config.cache.scope = :box
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
    d.run "leviathan",
          image: "ivanos/leviathan:multi-host-demo",
          args: "-v /run:/run -v /var:/host/var -v /proc:/host/proc --net=host --privileged=true -it"
  end

  INLINES.each |i| do
    config.vm.provision "shell", inline: i
  end

  (1..3).each do |i|
    config.vm.define "leviathan#{i}" do |node|
      node.vm.hostname = "leviathan#{i}"
      node.vm.network :forwarded_port, guest: 22, host: 2200+i, id: "ssh"
      node.vm.network :forwarded_port, guest: 8080, host: 8080+i
      node.vm.network :private_network, ip: "192.169.0.10#{i}"
      node.vm.provision "docker" do |d|
        d.run "cont#{2*i-1}"
        d.run "cont#{2*i}"
    end
  end
  
end
