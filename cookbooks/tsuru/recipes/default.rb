
# Sync time to prevent syncing issues between VM and local env
#execute "sync-time" do
#  command "ntpdate pool.ntp.org"
#end

# update apt-get list
#execute "initial-apt-get-update" do
#  command "apt-get update"
#end

# Our version of .bashrc has /home/vagrant/bin in PATH
#cookbook_file "/home/vagrant/.bashrc" do
#  source ".bashrc"
#  mode "0644"
#  owner "vagrant"
#  group "vagrant"
#  action :create
#end

#include_recipe "build-essential"
include_recipe "python"

package "python-dev" do
  action :install
end
# needed by tsuru
package "beanstalkd" do
  action :install
end

#package "python-pip" do
#  action :install
#end

# install virtualenv
#execute "install_virtualenv" do
#  command "/usr/bin/pip install virtualenv"
#  action :run
#end

# circusweb need event.h 
package "libevent-dev" do
  action :install
end

#execute "install_circus" do
#  command "/usr/bin/pip install circus"
#  action :run
#end
python_pip "circus"

#execute "install_tsuru-circus" do
#  command "/usr/bin/pip install tsuru-circus"
#  action :run
#end
python_pip "tsuru-circus"

execute "install_circusweb" do
  command "/usr/bin/pip install -r /usr/local/lib/python2.7/dist-packages/circus/web/web-requirements.txt"
  action :run
end


# Create a user: git
#user node[:tsuru][:username] do
#  comment   "git user"
#  home      node[:tsuru][:git_home_dir]
#  shell     "/bin/bash"
#  #password  "vagrant"
#  manage_home true  
#end

user_account node[:tsuru][:username] do
  comment   'git user'
  home      node[:tsuru][:git_home_dir]
  shell     "/bin/bash"
end

user_account 'ubuntu' do
  comment   'ubuntu user'
  home      '/home/ubuntu'
  shell     "/bin/bash"
end

directory node[:tsuru][:repos_dir] do
  owner node[:tsuru][:username]
  group node[:tsuru][:username]
  mode "0755"
  action :create
end

directory "/etc/tsuru" do
  mode "0755"
  action :create
end

directory "/etc/circus" do
  owner "root"
  group "root"
  mode 00755
  action :create
end

directory node[:tsuru][:tsuru_dir] do
  owner node[:tsuru][:username]
  group node[:tsuru][:username]
  mode "0755"
  action :create
end

template "/etc/tsuru/tsuru.conf" do
  source "tsuru.conf.erb"
  owner node[:tsuru][:username]
  group node[:tsuru][:username]  
  action :create
end

template "/etc/gandalf.conf" do
  source "gandalf.conf.erb"
  owner node[:tsuru][:username]
  group node[:tsuru][:username]
  action :create
end

template "/etc/circus/tsuru-circus.ini" do
  source "tsuru-circus.ini.erb"
  owner "git"
  group "git"
  mode 00644
  action :create
end

# Download tsuru, gandalf code and build it
execute "get_gandalf_code" do 
  user  "vagrant"
  group "vagrant"
  command "/home/vagrant/go/bin/go get github.com/globocom/gandalf/..."
  environment ({'GOROOT' => '/home/vagrant/go', 
                'GOPATH' => '/home/vagrant/.go', 
                'GOARCH' => 'amd64', 
                'GOOS' => 'linux'})
end

execute "get_tsuru_code" do
  user  "vagrant"
  group "vagrant"
  command "/home/vagrant/go/bin/go get github.com/globocom/tsuru/..."
  environment ({'GOROOT' => '/home/vagrant/go', 
                'GOPATH' => '/home/vagrant/.go', 
                'GOARCH' => 'amd64', 
                'GOOS' => 'linux'})
end

# get abyss code
execute "get-abyss-code" do
  user "vagrant"
  group "vagrant"
  cwd "/home/vagrant"
  command "/usr/bin/git clone https://github.com/globocom/abyss.git"
  creates "/home/vagrant/abyss"
  action :run
end

execute "get-new-abyss-code" do  
  user "vagrant"
  group "vagrant"
  cwd "/home/vagrant/abyss"
  command "git pull"
  action :run
end

execute "generate tls key file" do
  command "/usr/bin/openssl genrsa 1024 > /etc/tsuru/tls/key.pem"
  creates "/etc/tsuru/tls/key.pem"
end

#execute "generate tls cert file" do
#  command "/usr/bin/openssl req -x509 -new -key /etc/tsuru/tls/key.pem >> /etc/tsuru/tls/cert.pem"
#  creates "/etc/tsuru/tls/cert.pem"
#end

# create a virtualenv for abyss
#execute "create-abyss-venv" do
#  user  "vagrant"
#  group "vagrant"
#  cwd "/home/vagrant/abyss"
#  command "/usr/local/bin/virtualenv .venv"
#  creates "/home/vagrant/abyss/.venv"
#  action :run
#end

python_virtualenv "/home/vagrant/abyss/.venv" do
  owner "vagrant"
  group "vagrant"
  action :create
end

#bash "install-abyss-dependices" do
#  user  "vagrant"
#  group "vagrant"
#  cwd "/home/vagrant/abyss"
#  code <<-EOH
#    source .venv/bin/activate && /usr/bin/pip install -r ./test-requirements.txt
#  EOH
#end
python_pip "django" do
  virtualenv "/home/vagrant/abyss/.venv"
  version "1.5"
  action :install
end

python_pip "requests" do
  virtualenv "/home/vagrant/abyss/.venv"
  version "1.1.0"
  action :install
end

python_pip "gunicorn" do
  virtualenv "/home/vagrant/abyss/.venv"
  version "0.17.2"
  action :install
end

python_pip "mock" do
  virtualenv "/home/vagrant/abyss/.venv"
  version "1.0.1"
  action :install
end

bash "build-gandalf" do
  user "git"
  group "git"
  environment ({'GOROOT' => '/home/vagrant/go', 
                'GOPATH' => '/home/vagrant/.go', 
                'GOARCH' => 'amd64', 
                'GOOS' => 'linux'})
  cwd "/home/git"  
  code <<-EOH    
    mkdir -p dist
    rm dist/collector
    rm dist/webserver
    /home/vagrant/go/bin/go clean github.com/globocom/gandalf/...
    /home/vagrant/go/bin/go build -a -o dist/gandalf-webserver github.com/globocom/gandalf/webserver
    /home/vagrant/go/bin/go build -a -o dist/gandalf github.com/globocom/gandalf/bin    
  EOH
end

bash "build-tsuru" do
  user "git"
  group "git"
  environment ({'GOROOT' => '/home/vagrant/go', 
                'GOPATH' => '/home/vagrant/.go', 
                'GOARCH' => 'amd64', 
                'GOOS' => 'linux'})
  cwd "/home/git"  
  code <<-EOH
    mkdir -p dist
    /home/vagrant/go/bin/go clean github.com/globocom/tsuru/...
    /home/vagrant/go/bin/go build -a -o dist/collector github.com/globocom/tsuru/collector
    /home/vagrant/go/bin/go build -a -o dist/webserver github.com/globocom/tsuru/api    
    /home/vagrant/go/bin/go build -a -o dist/tsuru github.com/globocom/tsuru/cmd/tsuru/developer
    /home/vagrant/go/bin/go build -a -o dist/crane github.com/globocom/tsuru/cmd/crane
  EOH
end

service "mongodb" do
  action [ :enable, :start ]
end

service "beanstalkd" do
  action [ :enable, :start ]
end

execute "start-circus-process-monitor" do
  user "git"
  group "git"
  cwd "/home/git"
  command "/usr/local/bin/circusd --log-level debug --log-output circusd.log --pidfile circusd.pid --daemon /etc/circus/tsuru-circus.ini"
  action :run
end



