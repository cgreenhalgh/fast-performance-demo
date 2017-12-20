Vagrant.configure(2) do |config|
    config.vm.box = "ubuntu/trusty64"

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    # for tests (chrome)
    v.gui = true

    # Enable the VM's virtual USB controller & enable the virtual USB 2.0 controller
    v.customize ["modifyvm", :id, "--usb", "on", "--usbehci", "on"]
  end

  # node server for muzicodes
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  # nginx https proxy for muzicodes
  config.vm.network "forwarded_port", guest: 3443, host: 3443
  # node server for music-performance-manager
  config.vm.network "forwarded_port", guest: 3003, host: 3003
  # meld server
  config.vm.network "forwarded_port", guest: 5000, host: 5000
  # muzivisual test/dev only
  config.vm.network "forwarded_port", guest: 8000, host: 8000
  # meld client (avoid mrl-music 8080)
  config.vm.network "forwarded_port", guest: 8080, host: 8081

  # requires root :-(
  #config.vm.network "forwarded_port", guest: 80, host: 80

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    sudo apt-get update
    sudo apt-get install -y git zip
  SHELL

  # Muzicodes - see musiccodes/scripts

  # Meld pre-reqs - then see meld/README.md
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    sudo apt-get install -y python-pip python-dev
    sudo apt-get install -y python-dev libxml2-dev libxslt1-dev zlib1g-dev 
  
    # nginx reverse proxy - for presenting as remote servers
    #sudo apt-get install -y nginx

    # for mei xslt
    #sudo apt-get install -y xsltproc
    sudo apt-get install -y openjdk-7-jre-headless
    sudo apt-get install -y libsaxonb-java
  SHELL

  # nginx https frontend - what about hostname??
  #config.vm.provision "shell", privileged: false, inline: <<-SHELL
  #  sudo apt-get install -y nginx
  #  sudo update-rc.d nginx defaults
  #  
  #SHELL
  

end

