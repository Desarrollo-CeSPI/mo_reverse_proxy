node['mo_reverse_proxy']['applications'].each do |app|
  mo_reverse_proxy_block(app) do |id, data|
    if data['options']['access_log'] && data['options']['error_log']
      mo_collectd_nginx_log id,
        Array(data['options']['access_log']).first.split.first,
        Array(data['options']['error_log']).first.split.first,
        (data['action'] != :delete)
    end
  end
end
