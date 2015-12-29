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

$packages = <<SCRIPT
apt-get install -y emacs24-nox htop
SCRIPT

$docker_keys = <<SCRIPT
cd /home/vagrant/.ssh
docker exec leviathan mkdir -p /root/.ssh
docker cp id_rsa leviathan:/root/.ssh/id_rsa
SCRIPT

$leviathan_transfer = <<SCRIPT
DST=leviathan$2
SSH="ssh -o StrictHostKeyChecking=no -o Compression=no -c arcfour"
$SSH vagrant@leviathan1 docker save $1 | bzip2 | $SSH vagrant@$DST 'bunzip2 | docker load'
# $SSH vagrant@leviathan1 docker save $1 | $SSH vagrant@$DST 'docker load'
SCRIPT

$wait_for_leviathan_container = <<SCRIPT
until [ "`/usr/bin/docker inspect -f {{.State.Running}} leviathan`" == "true" ]; do
    sleep 0.2;
done;
SCRIPT

INLINES = [$ssh, $keys, $ipv4_forwarding, $packages]

def get_docker_images(node, host_id)
  if host_id == 1
    node.vm.provision "docker_images_leviathan1",
                      type: "docker",
                      images: [LINC_IMAGE, LEVIATHAN_IMAGE]
  else
    node.vm.provision "docker_images",
                      type: "docker",
                      images: [LEVIATHAN_IMAGE]
  # else
  #   node.vm.provision "docker_images_ssh",
  #                     type: "shell",
  #                     inline: $leviathan_transfer,
  #                     args: "#{LEVIATHAN_IMAGE} #{host_id}",
  #                     privileged: false
  end
end

def provision_docker(node, host_id)
  node.vm.provision "docker_containers", type: "docker" do |d|
    d.run "leviathan",
          image: LEVIATHAN_IMAGE,
          args: "-v /run:/run -v /var:/host/var -v /proc:/host/proc --net=host --privileged=true -it"
    d.run "cont#{2*host_id-1}", image: "ubuntu"
    d.run "cont#{2*host_id}", image: "ubuntu"
  end
  node.vm.provision "wait_for_leviathan_container",
                    type: "shell",
                    inline: $wait_for_leviathan_container
  node.vm.provision "ssh_keys",
                    type: "shell",
                    inline: $keys
  node.vm.provision "docker_keys",
                    type: "shell",
                    inline: $docker_keys
end

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
  config.ssh.forward_agent = true
  config.ssh.insert_key = false
  config.vm.synced_folder '.', '/vagrant'
  config.vm.boot_timeout = 60

  INLINES.each do |i|
    config.vm.provision "inlines", type: "shell", inline: i
  end

  (1..3).each do |i|
    config.vm.define "leviathan#{i}" do |node|
      node.vm.hostname = "leviathan#{i}"
      node.vm.network :forwarded_port, guest: 22, host: 2200+i, id: "ssh"
      node.vm.network :forwarded_port, guest: 8080, host: 8080+i
      node.vm.network :private_network, ip: "192.169.0.10#{i}"
      get_docker_images node, i
      provision_docker node, i
    end
  end
  
end
