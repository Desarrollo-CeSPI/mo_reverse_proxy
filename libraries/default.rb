include MoApplication::Nginx

def mo_reverse_proxy_access_log(name)
  node['mo_reverse_proxy']['log_formats'].map  do |log_name, data|
    (data['config'] || '%{log} %{name}') % {
      :log => ::File.join(node['nginx']['log_dir'], "#{data['prefix']}#{name}-access.log"),
      :name => log_name
    }
  end
end

def mo_reverse_proxy_to_nginx_log_formats
  Hash[node['mo_reverse_proxy']['log_formats'].map { |log_name, data| [log_name,data['format']] }]
end

def mo_reverse_proxy_error_log(name)
  ::File.join node['nginx']['log_dir'], "#{name}-error.log"
end

def mo_reverse_proxy_build_config(app_id, d)
  Hash.new.tap do |ret|
    (d['applications'] || Hash.new).each do |app_name, data|
      (data['reverse_proxy'] || Hash.new).each do |vhost, proxy_data| 
        id = "#{app_id}-#{app_name}-#{vhost}"
        proxy_data ||= Hash.new
        ret[id] = proxy_data
        ret[id]['monitoring'] ||= data['monitoring']
        ret[id]['allow'] ||= data['allow']
        ret[id]['port'] ||= proxy_data['ssl'] ? "443" : "80"
        ret[id]['server_name'] ||= data['server_name']
        ret[id]['upstreams'] ||= Array(d['application_servers']).map {|x| "server #{x}"}
        ret[id]['upstream_options'] ||= (data['upstream_options'] || Hash.new)
        ret[id]['options'] ||= (data['options'] || Hash.new)
        ret[id]['options'].merge!("access_log" => mo_reverse_proxy_access_log(app_id),
                                  "error_log"  => mo_reverse_proxy_error_log(app_id))
        ret[id]['action'] = d['remove'] || proxy_data['remove'] ? :delete : :create
      end
    end
  end
end

def mo_reverse_proxy_custom_locations(upstream_name, config)
  proxied_locations = config['proxied_locations'] || {}
  proxied_locations.each do  |name, data|
    data.merge! mo_reverse_proxy_location_options(upstream_name)
  end
  (config['locations'] || {}).merge(proxied_locations)
end

def mo_reverse_proxy_location_options(upstream_name)
  {
    "proxy_set_header" => {
      "X-Forwarded-For" => "$proxy_add_x_forwarded_for",
      "X-Forwarded-Proto" => "$scheme",
      "Host" => "$http_host"
    },
    'proxy_intercept_errors' => 'on',
    'proxy_redirect' => 'off',
    'proxy_pass' => "http://#{upstream_name}"
  }
end

def mo_reverse_proxy_locations(upstream_name, config)
  mo_reverse_proxy_custom_locations(upstream_name, config).merge(
    "/" => mo_reverse_proxy_location_options(upstream_name).
      merge(config['upstream_options']).
      merge(config['allow'] ? {"allow" => Array(config['allow']) + [node.ipaddress], "deny" => "all"} : {}))
end

def mo_reverse_proxy_certificates(config = {})
  Chef::Log.info("Trying to load #{node['mo_reverse_proxy']['certificate_databag']}/#{config['ssl_certificate'] || node['mo_reverse_proxy']['certificate_databag_item']}")
  certificates = Chef::EncryptedDataBagItem.load(node['mo_reverse_proxy']['certificate_databag'], config['ssl_certificate'] || node['mo_reverse_proxy']['certificate_databag_item'])
  {
    "public"  => certificates["cert"] + String(certificates['chain']),
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
    action config['action']
    notifies :reload, "service[nginx]"
  end
end


def _mo_reverse_proxy_direct(name, config)
  raise "Can't configure a reverse proxy for #{name} with empty upstreams. Check appplication configuration" if config['upstreams'].empty?
  nginx_conf_file "#{name}.conf" do
    listen Array(config['port']).map {|x| config['ssl'] ? "#{x} ssl spdy" : x }
    upstream name => config['upstreams']
    server_name config['server_name']
    locations mo_reverse_proxy_locations(name, config)
    if config['ssl']
      ssl mo_reverse_proxy_certificates(config)
      options node['mo_reverse_proxy']['ssl_default_options'].merge(config['options'] || Hash.new).merge(ssl_dhparam: mo_reverse_proxy_ssl_dhparam_filename)
    else
      options config['options']
    end
    action config['action']
    notifies :reload, "service[nginx]"
  end
end

def mo_reverse_proxy(app)
  [].tap do |vhosts|
    mo_reverse_proxy_block(app) do |id, data|
      if data['redirect']
        _mo_reverse_proxy_redirect(id, data)
      else
        _mo_reverse_proxy_direct(id, data)
      end
      vhosts << "#{id}.conf"
    end
  end
end

def mo_reverse_proxy_block(app, &block)
    mo_data_bag_for_environment(node['mo_reverse_proxy']['applications_databag'], app).tap do |d|
      mo_reverse_proxy_build_config(app, d).each do |id, data|
        block.call(id, data)
      end
    end
end

def catch_all_site
  ssl_certificates = mo_reverse_proxy_certificates rescue nil
  nginx_conf_catch_all_site( "default_catch_all_404",
                             "ssl_certificates" => ssl_certificates,
                             "ssl_options" => node['mo_reverse_proxy']['ssl_default_options'])
end

def mo_reverse_proxy_ssl_dhparam_filename
  ::File.join(node["nginx"]["dir"], "dhparams.pem")
end
