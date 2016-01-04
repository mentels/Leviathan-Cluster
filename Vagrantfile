LINC_IMAGE = "mentels/dockerfiles:linc-multi-host-demo"
LEVIATHAN_IMAGE = "mentels/dockerfiles:leviathan-multi-host-demo"

$ssh_config = <<SCRIPT
SSHD_CONFIG="/etc/ssh/sshd_config"
TUNNEL="PermitTunnel yes"
cat ${SSHD_CONFIG} | grep "${TUNNEL}"  || \
echo -e "\n${TUNNEL}" >> ${SSHD_CONFIG} && service ssh reload
SCRIPT

$ssh_keys = <<SCRIPT
cd /home/vagrant/.ssh
cp /vagrant/keys/id_rsa* .
cat id_rsa.pub >> authorized_keys
chown vagrant: id_rsa*
SCRIPT

$ipv4_forwarding = <<SCRIPT
IP_FORWARD="net.ipv4.ip_forward=1"
SYSCTL_CONF="/etc/sysctl.conf"
sysctl -w ${IP_FORWARD}
cat ${SYSCTL_CONF} | grep "^${IP_FORWARD}" || echo ${IP_FORWARD} >> ${SYSCTL_CONF}
SCRIPT

$packages = <<SCRIPT
apt-get install -y emacs24-nox htop bridge-utils
SCRIPT

$docker_keys = <<SCRIPT
cd /home/vagrant/.ssh
docker exec leviathan mkdir -p /root/.ssh
docker cp id_rsa leviathan:/root/.ssh/id_rsa
SCRIPT

$docker_image_transfer = <<SCRIPT
DST=leviathan$2
SSH="ssh -o StrictHostKeyChecking=no -o Compression=no -c arcfour"
$SSH vagrant@leviathan1 docker save $1 | bzip2 | $SSH vagrant@$DST 'bunzip2 | docker load'
SCRIPT

$wait_for_leviathan_container = <<SCRIPT
until [ "`/usr/bin/docker inspect -f {{.State.Running}} leviathan`" == "true" ]; do
    sleep 0.2;
done;
SCRIPT

def provision_with_shell(node)
  node.vm.provision "ssh_config", type: "shell", inline: $ssh_config
  node.vm.provision "ssh_keys", type: "shell", inline: $ssh_keys
  node.vm.provision "ipv4_forwarding", type: "shell", inline: $ipv4_forwarding
  node.vm.provision "packages", type: "shell", inline: $packages
end

def transfer_image(node, name, image, host_id)
  node.vm.provision name,
                    type: "shell",
                    inline: $docker_image_transfer,
                    args: "#{image} #{host_id}",
                    privileged: false
end

def get_docker_images(node, host_id)
  node.vm.provision "docker_exec", type: "docker"
  if host_id == 1
    node.vm.provision "docker_images_leviathan1",
                      type: "docker",
                      images: [LINC_IMAGE, LEVIATHAN_IMAGE, "ubuntu:latest"]
    node.vm.provision "docker_rename_linc",
                      type: "shell",
                      inline: "docker tag #{LINC_IMAGE} local/linc"
  else
    transfer_image node, "transfer_leviathan", LEVIATHAN_IMAGE, host_id
    transfer_image node, "transfer_ubnuntu", "ubuntu:latest", host_id
  end
end

def run_ubuntu_container(provisioner, name)
  provisioner.run name,
                  image: "ubuntu",
                  args: "-it --net=none",
                  restart: "no"
end

def provision_docker_container(node, host_id)
  node.vm.provision "docker_containers", type: "docker" do |d|
    d.run "leviathan",
          image: LEVIATHAN_IMAGE,
          args: "-v /run:/run -v /var:/host/var -v /proc:/host/proc --net=host --privileged=true -it",
          restart: "no"
    run_ubuntu_container d, "cont#{2*host_id-1}"
    run_ubuntu_container d, "cont#{2*host_id}"
  end
  node.vm.provision "wait_for_leviathan_container",
                    type: "shell",
                    inline: $wait_for_leviathan_container
  node.vm.provision "docker_keys",
                    type: "shell",
                    inline: $docker_keys
end

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 4096
    vb.cpus = 4
    vb.linked_clone = true
  end
  
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = false
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.ssh.forward_agent = true
  config.ssh.insert_key = false
  config.vm.synced_folder '.', '/vagrant'
  config.vm.boot_timeout = 60

  (1..3).each do |i|
    config.vm.define "leviathan#{i}" do |node|
      node.vm.hostname = "leviathan#{i}"
      node.vm.network :forwarded_port, guest: 22, host: 2200+i, id: "ssh"
      node.vm.network :forwarded_port, guest: 8080, host: 8080+i
      node.vm.network :private_network, ip: "192.169.0.10#{i}"
      provision_with_shell node
      get_docker_images node, i
      provision_docker_container node, i
    end
  end
  
end
