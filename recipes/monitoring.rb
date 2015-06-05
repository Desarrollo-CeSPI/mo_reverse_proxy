node['mo_reverse_proxy']['applications'].each do |app_id|
  app_data = data_bag_item(node['mo_reverse_proxy']['applications_databag'], app_id)
  if app_data[node.chef_environment] 
    (app_data[node.chef_environment]['applications'] || Hash.new).each do |app_name, app|
      if app['reverse_proxy'] and app['reverse_proxy']['ssl']

      server_name = Array(app['server_name']).first
      check_name = "ssl-cert_#{server_name}"

        nrpe_check check_name do
          command "#{node["mo_monitoring_client"]["install_directory"]}/check_ssl_cert"
          warning_condition node['mo_monitoring_client']['plugins']['check_ssl_cert']['warning_condition']
          critical_condition node['mo_monitoring_client']['plugins']['check_ssl_cert']['critical_condition']
          parameters "-A -H #{server_name}"
          notifies :restart, "service[#{node['nrpe']['service_name']}]"
        end

      end
    end
  end
end
