include_recipe "mo_monitoring_client"
node['mo_reverse_proxy']['applications'].each do |app|
  mo_reverse_proxy_block(app) do |id, data|

    if data['ssl']

      server_name = Array(data['server_name']).first
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
