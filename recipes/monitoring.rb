node['mo_reverse_proxy']['applications'].each do |app_id|
  data_bag_item(node['mo_reverse_proxy']['applications_databag'], app_id) do |app_data|
    app_data[node.chef_environment]['applications'].each do |app|
      if app['ssl']
        app['server_name'].each do |server_name|

          check_name = "ssl_#{server_name}"

          nrpe_check check_name do
            command "#{node["mo_monitoring_client"]["install_directory"]}/#{name}"
            warning_condition node['mo_monitoring_client']['plugins']['check_ssl_cert']['warning_condition']
            critical_condition node['mo_monitoring_client']['plugins']['check_ssl_cert']['critical_condition']
            parameters node['mo_monitoring_client']['plugins']['check_ssl_cert']['parameters']
            notifies :restart, "service[#{node['nrpe']['service_name']}]"
          end

        end
      end
    end
  end
end
