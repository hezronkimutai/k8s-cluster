Vagrant.configure("2") do |config|
  nodes = {
    "master" => "192.168.56.10",
    "worker1" => "192.168.56.11",
    "worker2" => "192.168.56.12"
  }

  config.vm.box = "ubuntu/focal64"

  nodes.each do |name, ip|
    config.vm.define name do |node|
      node.vm.hostname = name
      node.vm.network "private_network", ip: ip
      node.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.cpus = 2
      end
      node.vm.provision "shell", inline: <<-SHELL
        apt-get update
        apt-get install -y curl containerd apt-transport-https
        swapoff -a
        sed -i '/ swap / s/^/#/' /etc/fstab
      SHELL
    end
  end
end
