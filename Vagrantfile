# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "dummy"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider :aws do |aws, override|
    aws.access_key_id =  ENV['AWS_ACCESS_KEY_ID']
    aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    aws.keypair_name = ENV['VAGRANT_KEY_PAIR']

    aws.ami = ENV['VAGRANT_NAME']
    aws.instance_type = "t2.micro"
    aws.region = ENV['AWS_RESION']
    aws.subnet_id = ENV['VAGRANT_SUBNET_ID']
    aws.security_groups = ENV['VAGRANT_SECURITY_GROUPS']

    override.ssh.username = "ec2-user"
    override.ssh.private_key_path = "/root/.ssh/id_rsa"
  end
end
