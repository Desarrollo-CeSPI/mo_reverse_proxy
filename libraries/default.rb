def mo_reverse_proxy_build_config(app_id, d)
  Hash.new.tap do |ret|
    (d['applications'] || Hash.new).each do |app_name, data|
      data['reverse_proxy'].each do |vhost, proxy_data| 
        id = "#{app_id}-#{app_name}-#{vhost}"
        proxy_data ||= Hash.new
        ret[id] = proxy_data
        ret[id]['port'] ||= proxy_data['ssl'] ? "443" : "80"
        ret[id]['server_name'] ||= data['server_name']
        ret[id]['upstreams'] ||= Array(d['application_servers']).map {|x| "server #{x}"}
        ret[id]['options'] ||= data['options'] || Hash.new
        ret[id]['action'] = d['remove'] || proxy_data['remove'] ? :delete : :create
      end
    end
  end
end

def mo_reverse_proxy_locations(upstream_name)
  {
    "/" => {
      "proxy_set_header" => {
        "X-Forwarded-For" => "$proxy_add_x_forwarded_for",
        "X-Forwarded-Proto" => "$scheme",
        "Host" => "$http_host"
      },
      'proxy_redirect' => 'off',
      'proxy_pass' => "http://#{upstream_name}"
    }
  }
end

def mo_reverse_proxy_certificates(config)
  Chef::Log.info("Trying to load #{node['mo_reverse_proxy']['certificate_databag']}/#{config['ssl_certificate'] || node['mo_reverse_proxy']['certificate_databag_item']}")
  certificates = Chef::EncryptedDataBagItem.load(node['mo_reverse_proxy']['certificate_databag'], config['ssl_certificate'] || node['mo_reverse_proxy']['certificate_databag_item'])
  {
    "public"  => certificates["cert"],
    "private" => certificates["key"]
  }
end

def _mo_reverse_proxy_redirect(name, config)
  nginx_conf_file "#{name}.conf" do
    listen config['port']
    server_name config['server_name']
    block "rewrite ^(.*) #{config['redirect']}$1 permanent;"
    site_type :static
    if config['ssl']
      ssl mo_reverse_proxy_certificates(config)
    end
    notifies :reload, "service[nginx]"
  end
end


def _mo_reverse_proxy(name, config)
  nginx_conf_file "#{name}.conf" do
    listen Array(config['port']).map {|x| config['ssl'] ? "#{x} default_server ssl spdy" : x }
    upstream name => config['upstreams']
    server_name config['server_name']
    locations mo_reverse_proxy_locations(name)
    if config['ssl']
      ssl mo_reverse_proxy_certificates(config)
      options node['mo_reverse_proxy']['ssl_default_options'].merge(config['options'] || Hash.new)
    else
      options config['options']
    end
    notifies :reload, "service[nginx]"
  end
end

def mo_reverse_proxy(app)
  mo_data_bag_for_environment(node['mo_reverse_proxy']['applications_databag'], app).tap do |d|
    mo_reverse_proxy_build_config(app, d).each do |id, data|
      if data['redirect']
        _mo_reverse_proxy_redirect(id, data)
      else
        _mo_reverse_proxy(id, data)
      end
    end
  end
end
