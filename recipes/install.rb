node.set['nginx']['client_max_body_size'] = '40m'
node.set['nginx']['log_formats'] = mo_reverse_proxy_to_nginx_log_formats

if node['mo_reverse_proxy']['use_upstream_repo']
  node.set['nginx']['upstream_repository'] = "http://nginx.org/packages/#{node['platform']}" if node['platform_family'] == 'ubuntu'
  include_recipe 'nginx::repo'
end

include_recipe 'nginx::default'
include_recipe 'nginx::http_stub_status_module'

execute "Generating DH group" do
  command "openssl dhparam -out #{mo_reverse_proxy_ssl_dhparam_filename} 2048"
  not_if "test -s #{mo_reverse_proxy_ssl_dhparam_filename}"
  notifies :restart, 'service[nginx]'
end


catch_all_site

directory node['nginx']['log_dir'] do
  group node['rsyslog']['group']
end
