Vagrant.configure("2") do |config|
  nodes = {
    "master" => "192.168.56.10",
    "worker1" => "192.168.56.11"
  }

  config.vm.box = "ubuntu/focal64"
  config.ssh.insert_key = false  # Helps avoid SSH key mismatch issues
  
  # SSH timeout fixes
  config.ssh.connect_timeout = 15
  config.ssh.guest_port = 22
  config.vm.boot_timeout = 900
  config.vm.graceful_halt_timeout = 60

  nodes.each do |name, ip|
    config.vm.define name do |node|
      node.vm.hostname = name
      node.vm.network "private_network", ip: ip

      node.vm.provider "virtualbox" do |vb|
        if name == "master"
          vb.memory = 2048
          vb.cpus = 2
        else
          vb.memory = 1024
          vb.cpus = 1
        end
        
        # VirtualBox optimizations
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
        vb.customize ["modifyvm", :id, "--uartmode1", "file", File::NULL]
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
