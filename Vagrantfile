# -*- mode: ruby -*-
# vi: set ft=ruby :

concourse_port=9080

Vagrant.configure("2") do |config|
  config.vm.box = "bento/debian-10"
  config.vm.box_version = "202102.02.0"
#  config.vm.network "forwarded_port", guest: 8080, host: concourse_port

  config.vm.provision "file", source: "#{__dir__}/provisioning", destination: "/tmp/provisioning"
  config.vm.provision "shell", inline: "chmod +x /tmp/provisioning/core && /tmp/provisioning/core"
end
