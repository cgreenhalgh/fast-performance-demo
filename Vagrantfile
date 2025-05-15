# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "bento/ubuntu-22.04"


  # Disable automatic box update checking. 
  config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # node server for muzicodes
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  # node server for music-performance-manager
  config.vm.network "forwarded_port", guest: 3003, host: 3003
  #, host_ip: "127.0.0.1"
  # meld server
  config.vm.network "forwarded_port", guest: 5000, host: 5000
  # meld client (avoid mrl-music 8080)
  config.vm.network "forwarded_port", guest: 8080, host: 8081

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Provider-specific configuration for VirtualBox:
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    #vb.gui = true

    # Customize the amount of memory on the VM:
    vb.memory = "2048"
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # docker provisioner... (just install it)
  config.vm.provision "docker" do |d|
    #d.pull_images "ubuntu"
  end
  
  # Provisioning
  config.vm.provision "shell", inline: <<-SHELL
    #apt update
    # docker-compose replaced by docker compose
    cd /vagrant
    docker compose up -d
    
    # one-time setup?!
    ./scripts/setup.sh
  SHELL
  config.vm.provision "shell", run: "always", inline: <<-SHELL
    # work-around for race condition with docker restart and vagrant mount
    cd /vagrant
    docker compose restart
  SHELL
  
end
