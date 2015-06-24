include_recipe "mo_reverse_proxy::install"

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
