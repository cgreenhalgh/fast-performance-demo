Vagrant.configure(2) do |config|
    config.vm.box = "ubuntu/trusty64"

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    # for tests (chrome)
    v.gui = true
  end

  # node server for muzicodes
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  # meld server
  config.vm.network "forwarded_port", guest: 5000, host: 5000
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

  SHELL

  

end

