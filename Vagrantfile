# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.5.0"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  config.vm.define 'reverse_proxy', primary: true do |app|
    app.vm.hostname = "proxy.vagrant.desarrollo.unlp.edu.ar"
    app.omnibus.chef_version = "11.16.4"
    app.vm.box = "chef/ubuntu-14.04"
    app.vm.network :private_network, ip: "10.100.8.2"
    app.berkshelf.enabled = true
    app.vm.provision :chef_solo do |chef|
      chef.data_bags_path = 'sample/data_bags'
      chef.environment = 'vagrant'
      chef.environments_path = 'sample/environments'
      chef.encrypted_data_bag_secret_key_path = 'sample/.chef/data_bag_key'
      chef.json = {
        mo_reverse_proxy:{
          applications: ['kimkelen'],
          certificate_databag_item: "test"
        }
      }
      chef.run_list = [
        "recipe[apt]",
        "recipe[mo_reverse_proxy]"
      ]
    end
  end

end
