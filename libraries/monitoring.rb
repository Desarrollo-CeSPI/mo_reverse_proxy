def server_name_for(data)
  Array(data['server_name']).first
end

def mo_reverse_proxy_monitor_http_expected_codes
  "200,401,301,302"
end

def mo_reverse_proxy_monitor_ssl(data)
  check_name = "ssl-cert_#{server_name_for data}"
  nrpe_check check_name do
    command "#{node["mo_monitoring_client"]["install_directory"]}/check_ssl_cert"
    warning_condition node['mo_monitoring_client']['plugins']['check_ssl_cert']['warning_condition']
    critical_condition node['mo_monitoring_client']['plugins']['check_ssl_cert']['critical_condition']
    parameters "-A -H #{server_name_for data}"
    notifies :restart, "service[#{node['nrpe']['service_name']}]"
  end
end

def mo_reverse_proxy_monitor_http(data)
  check_name = "check-http_#{server_name_for data}"
  check_name += "-ssl" if data['ssl']
  nrpe_check check_name do
    command "#{node['nrpe']['plugin_dir']}/check_http"
    parameters "-e #{mo_reverse_proxy_monitor_http_expected_codes} -I #{node.ipaddress} -H #{server_name_for data} #{data['ssl'] ? '-S': ''}"
    notifies :restart, "service[#{node['nrpe']['service_name']}]"
  end
end
