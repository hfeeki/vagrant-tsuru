default[:tsuru][:username] = "vagrant"
default[:tsuru][:git_home_dir] = "/home/git"
default[:tsuru][:repos_dir] = "/home/git/repositories"
default[:tsuru][:tsuru_dir] = "/home/git/tsuru"

default[:tsuru][:gandalf_dir] = "/home/git/gandalf"
default[:tsuru][:circus_web_port] = 3333

default[:tsuru][:db_url] = "127.0.0.1:27017"
default[:tsuru][:tsuru_db_name] = "tsuru"
default[:tsuru][:gandalf_db_name] = "gandalf"
default[:tsuru][:gandalf_host] = "gandalfhost.com"
default[:tsuru][:gandalf_web_port] = 8000
default[:tsuru][:git_port] = 7080
default[:tsuru][:use_tls] = false
default[:tsuru][:webserver] = "0.0.0.0:8080"

