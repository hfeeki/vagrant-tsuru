#/usr/bin/env bash
# cd baseboxes
# vagrant basebox build ubuntu-12.10-amd64
# vagrant basebox export ubuntu-12.10-amd64
# cd -
# vagrant up 

# for vagrant 1.3.5
git clone https://github.com/jedi4ever/veewee.git
cd veewee
gem install bundler
bundle install
bundle exec veewee vbox define ubuntu-12.10-amd64 ubuntu-12.10-server-amd64
bundle exec veewee vbox build 'ubuntu-12.10-amd64' --workdir=/Users/michael/repos/veewee
bundle exec veewee vbox export ubuntu-12.10-amd64
vagrant box add 'ubuntu-12.10-amd64' '/Users/michael/repos/veewee/ubuntu-12.10-amd64.box'
cd -
vagrant up
