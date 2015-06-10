execute "Generating DH group" do
  command "openssl dhparam -out #{mo_reverse_proxy_ssl_dhparam_filename} 2048"
  not_if "test -s #{mo_reverse_proxy_ssl_dhparam_filename}"
end

include_recipe 'nginx::default'
include_recipe 'nginx::http_stub_status_module'

catch_all_site

vhosts = []

# Create vhosts for reverse proxy, tracking new additions in vhosts
node['mo_reverse_proxy']['applications'].each do |app_name|
    vhosts += mo_reverse_proxy(app_name)
end

vhosts.uniq!
# Remove vhosts not used anymore
(node['mo_reverse_proxy']['vhosts'] - vhosts).each do |name|
  nginx_conf_file name do
    action :delete
  end
end

node.set['mo_reverse_proxy']['vhosts'] = vhosts
