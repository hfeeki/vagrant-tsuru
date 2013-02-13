
# Sync time to prevent syncing issues between VM and local env
#execute "sync-time" do
#  command "ntpdate pool.ntp.org"
#end

# update apt-get list
execute "initial-sudo-apt-get-update" do
  command "apt-get update"
end

# Our version of .bashrc has /home/vagrant/bin in PATH
#cookbook_file "/home/vagrant/.bashrc" do
#  source ".bashrc"
#  mode "0644"
#  owner "vagrant"
#  group "vagrant"
#  action :create
#end

# Install git
#include_recipe "git"

# Install bazaar
#include_recipe "bazaar"

# Add a user: git
include_recipe "user"

user_account 'git' do
  comment   'git user'
  home      '/home/git'
  create_group 'true'
  password  'vagrant'
end

directory node[:tsuru][:repos_dir] do
  owner "git"
  mode "0755"
  action :create
end

directory node[:tsuru][:tsuru_dir] do
  owner "git"
  mode "0755"
  action :create
end

template "/etc/tsuru.conf" do
  source "tsuru.conf.erb"
  owner "git"
  group "git"
  variables({
    :tsuru_db_url   => node[:tsuru][:db_url],
    :tsuru_db_name  => node[:tsuru][:tsuru_db_name],
    :git_port       => node[:tsuru][:git_port]
  })
  action :create
end

# Download tsuru, gandalf code and build it
go get github.com/globocom/gandalf/...
go get github.com/globocom/tsuru/...

