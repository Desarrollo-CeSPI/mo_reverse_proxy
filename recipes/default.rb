include_recipe 'nginx::default'

catch_all_site

node['mo_reverse_proxy']['applications'].each do |app_name|
    mo_reverse_proxy(app_name)
end
