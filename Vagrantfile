LINC_IMAGE = "mentels/dockerfiles:linc-multi-host-demo"
LEVIATHAN_IMAGE = "mentels/dockerfiles:leviathan-multi-host-demo"

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

$pv = <<SCRIPT
apt-get install -y pv
SCRIPT

$docker_keys = <<SCRIPT
cd /home/vagrant/.ssh
docker exec leviathan mkdir -p /root/.ssh
docker cp id_rsa leviathan:/root/.ssh/id_rsa
SCRIPT

$leviathan_transfer = <<SCRIPT
ssh -o StrictHostKeyChecking=no vagrant@leviathan1 docker save #{LEVIATHAN_IMAGE} | bzip2 | pv | ssh -o StrictHostKeyChecking=no vagrant@leviathan#$1 'bunzip2 | docker load'
SCRIPT

INLINES = [$ssh, $keys, $ipv4_forwarding, $emacs, $pv]

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 4096
    vb.cpus = 4
  end
  
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.cache.scope = :box
  config.ssh.forward_agent = true
  config.vm.synced_folder '.', '/vagrant'
  config.vm.boot_timeout = 60

  config.vm.provision "docker" do |d|
    d.version =  "1.9.1"
  end

  INLINES.each do |i|
    config.vm.provision "shell", inline: i
  end

  (1..3).each do |i|
    config.vm.define "leviathan#{i}" do |node|
      node.vm.hostname = "leviathan#{i}"
      node.vm.network :forwarded_port, guest: 22, host: 2200+i, id: "ssh"
      node.vm.network :forwarded_port, guest: 8080, host: 8080+i
      node.vm.network :private_network, ip: "192.169.0.10#{i}"

      if i == 1
        node.vm.provision "docker", images: [LINC_IMAGE]
      end

      if i != 1
        node.vm.provision "shell", inline: $leviathan_transfer, args: "#{i}"
        node.vm.provision "docker" do |d|
          d.run "leviathan",
                image: LEVIATHAN_IMAGE,
                args: "-v /run:/run -v /var:/host/var -v /proc:/host/proc --net=host --privileged=true -it"
          d.run "cont#{2*i-1}", image: "ubuntu"
          d.run "cont#{2*i}", image: "ubuntu"
        end
      end
      node.vm.provision "shell", inline: $docker_keys  
    end
  end
  
end
