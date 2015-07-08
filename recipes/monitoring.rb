require 'chef/mixin/shell_out'

shell_out("rm #{node['nrpe']['conf_dir']}/nrpe.d/{ssl-cert,check-http}_*").run_command

include_recipe "mo_monitoring_client"

node['mo_reverse_proxy']['applications'].each do |app|
  mo_reverse_proxy_block(app) do |id, data|

    mo_reverse_proxy_monitor_http(data)
    mo_reverse_proxy_monitor_ssl(data) if data['ssl']

  end
end
