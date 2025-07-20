Vagrant.configure("2") do |config|
  nodes = {
    "master" => "192.168.56.10",
    "worker1" => "192.168.56.11"
  }

  config.vm.box = "ubuntu/focal64"
  config.ssh.insert_key = false  # Helps avoid SSH key mismatch issues

  nodes.each do |name, ip|
    config.vm.define name do |node|
      node.vm.hostname = name
      node.vm.network "private_network", ip: ip
      node.vm.boot_timeout = 600

      node.vm.provider "virtualbox" do |vb|
        if name == "master"
          vb.memory = 2048
          vb.cpus = 2
        else
          vb.memory = 1024
          vb.cpus = 1
        end
      end

      node.vm.provision "shell", inline: <<-SHELL
        export DEBIAN_FRONTEND=noninteractive
        apt-get update
        apt-get install -y curl containerd apt-transport-https
        swapoff -a
        sed -i '/ swap / s/^/#/' /etc/fstab
      SHELL
    end
  end
end
