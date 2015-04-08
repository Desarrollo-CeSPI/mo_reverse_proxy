include_recipe "mo_application::backup"
include_recipe "mo_backup::install"

data = Hash.new
data['backup']            ||= Hash.new
data['backup']['user']      = backup_default_user(data)
data['backup']['notifiers'] = backup_default_notifiers
data['backup']['storages']  = backup_default_storages

backup_name = "reverse-proxy-#{node.fqdn}"

mo_backup backup_name do
  archives  node['nginx']['log_dir']
  storages  data['backup']['storages']
  notifiers data['backup']['notifiers']
  user data['backup']['user']
end
