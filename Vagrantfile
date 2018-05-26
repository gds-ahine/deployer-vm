#$set_aws_default = <<AWS_DEFAULT
#tee ".aws/default" > "/dev/null" <<EOF
#export AWS_MFA_ROLE_ARN=#{ENV['AWS_MFA_ROLE_ARN']}
#export AWS_MFA_ARN=#{ENV['AWS_MFA_ARN']}"
#EOF
#AWS_DEFAULT

# Configure AWS credentials
$set_aws_creds = <<AWS_CREDS
tee ".aws/credentials" > "/dev/null" <<EOF
[default]
aws_default_region=#{ENV['AWS_DEFAULT_REGION']}
aws_access_key_id=#{ENV['AWS_ACCESS_KEY_ID']}
aws_secret_access_key=#{ENV['AWS_SECRET_ACCESS_KEY']}
EOF
AWS_CREDS

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.provision :shell, path: "bootstrap.sh"
  #config.vm.provision "file", source: "~/.ssh/config", destination: "~/.ssh/config"
  # uncomment the following line if you need to sync a local directory to the VM
  config.vm.synced_folder "<source directory on host to sync>", "<destination directory to sync to>"
  #config.vm.provision "shell", inline: $set_aws_config, run: "always"
  config.vm.provision "shell", inline: $set_aws_creds, run: "always"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "deployer-vm"
  end

  # Following config will allow you to use SSH authentication with Yubikey
  #
  # This filter uses VirtualBox as provider. 
  #
  # !! Default config is for Yubikey NEO !!
  #
  # Linux: use lsusb for get Vendor & product IDs, Mac OSX: System Profiles -> USB
  #
  # For Yubikey 4 you may need to change the vendor ID to 0x1050 and product ID to 0x0407 (see above to confirm)
  # 
  # Alter the Product variable for your model of Yubikey

  FILTER_NAME="YubiKey"
  MANUFACTURER="Yubico"
  VENDOR_ID="0x1050"
  PRODUCT_ID="0x0116"
  PRODUCT="Yubikey NEO OTP+U2F+CCID"

  config.vm.provider "virtualbox" do |vb|
    vb.customize ['modifyvm', :id, '--usb', 'on']
    vb.customize ['usbfilter', 'add', '0', 
      '--target', :id, 
      '--name', FILTER_NAME, 
      '--manufacturer', MANUFACTURER,
      '--vendorid', VENDOR_ID, 
      '--productid', PRODUCT_ID, 
      '--product', PRODUCT]
  end
end
