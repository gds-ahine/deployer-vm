#!/usr/bin/env bash

terraform_version="0.11.7"

# install required packages
apt-get update
apt-get upgrade -y
apt-get install python-pip -y
apt-get install python -y
apt-get install default-jdk -y
apt-get install git -y
apt-get install unzip -y
apt-get install jq -y
apt-get install gnupg-agent -y
apt-add-repository ppa:yubico/stable
apt-get update
apt-get install yubikey-personalization-gui yubikey-neo-manager yubikey-personalization -y
apt-get install pcscd scdaemon gnupg2 pcsc-tools -y
apt-get install software-properties-common -y
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
apt-add-repository "deb http://ppa.launchpad.net/ansible/ansible/ubuntu xenial main"
apt-get update
apt-get install ansible -y
pip install awscli --user
ln -s ~vagrant/.local/bin/aws /usr/bin/aws

# symlink gpg to gpg2
mv /usr/bin/gpg /usr/bin/gpg_old_binary
ln -s /usr/bin/gpg2 /usr/bin/gpg

# check if .gnupg diretory exists if not create it
if [ ! -d .gnupg ]; then
        mkdir .gnupg
fi

# setup gpg-agent for Yubikey SSH auth
echo "use-agent" >> .gnupg/gpg.conf
echo "enable-ssh-support" > .gnupg/gpg-agent.conf
echo "pinentry-program /usr/bin/pinentry-curses" >> .gnupg/gpg-agent.conf
echo "default-cache-ttl 60" >> .gnupg/gpg-agent.conf
echo "max-cache-ttl 120" >> .gnupg/gpg-agent.conf
printf '%%Assuan%%\nsocket=/dev/shm/S.gpg-agent\n' > .gnupg/S.gpg-agent
chown -R vagrant:vagrant .gnupg

# hacky way to stop the GPG agent if already running - cannot get this to run properly from shell script or .bashrc
unset SSH_AUTH_SOCK
sudo kill -15 $(ps auxwww|grep gpg-agent | grep -v grep | awk {'print $2'})
#echo "eval $(gpg-agent --homedir /home/vagrant/.gnupg --use-standard-socket --daemon)" >> start-gpg-agent.sh 

# download Terraform , gpg public key and SHA256 hashes  - why no PPA Hashicorp :(
# check integrity of file and install if ok
curl -o terraform_$terraform_version_linux_amd64.zip https://releases.hashicorp.com/terraform/$terraform_version/terraform_$terraform_version_linux_amd64.zip
curl -o terraform_$terraform_version_SHA256SUMS  https://releases.hashicorp.com/terraform/$terraform_version/terraform_$terraform_version_SHA256SUMS
curl -o terraform_$terraform_version_SHA256SUMS.sig https://releases.hashicorp.com/terraform/$terraform_version/terraform_$terraform_version_SHA256SUMS.sig
curl -o hashicorp.asc https://keybase.io/hashicorp/pgp_keys.asc?fingerprint=91a6e7f85d05c65630bef18951852d87348ffc4c
gpg --import hashicorp.asc
gpg --verify terraform_$terraform_version_linux_amd64.zip terraform_$terraform_version_SHA256SUMS

check_integrity=$(sha256sum -c terraform_0.11.7_SHA256SUMS terraform_0.11.7_linux_amd62.zip 2>/dev/null | grep -v FAILED)
sha256output=$(echo $check_integrity | cut -d ':' -f2 | sed 's/^.//')

if [ ! $sha256output = "OK" ]; then
        exit
else
        echo "Terraform binary integrity is GOOD"
        mv terraform /usr/local/bin
fi

# update motd files with instructions
echo "Enter the following command to start the GPG agent for Yubikey SSH authentication -:" > /etc/motd
echo >> /etc/motd
echo "eval \$(gpg-agent --homedir /home/vagrant/.gnupg --use-standard-socket --daemon)" >> /etc/motd
echo >> /etc/motd
cp /etc/motd /etc/issue
cp /etc/motd /etc/issue.net
sed -i 's/^#Banner/Banner/' /etc/ssh/sshd_config

if [ ! -d .aws ]; then
	mkdir .aws
	touch .aws/config
	touch .aws/credentials
fi

chown -R vagrant:vagrant .aws
