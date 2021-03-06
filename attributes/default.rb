default['mo_reverse_proxy']['certificate_databag'] = 'certificates'
default['mo_reverse_proxy']['certificate_databag_item'] = nil
default['mo_reverse_proxy']['application_servers'] = []
default['mo_reverse_proxy']['applications'] = []
default['mo_reverse_proxy']['vhosts'] = []
default['mo_reverse_proxy']['applications_databag'] = 'applications'
default['mo_reverse_proxy']['ssl_default_options'] = {
  "ssl_protocols"             => "TLSv1.2 TLSv1.1 TLSv1",
  "ssl_prefer_server_ciphers" => "on",
  "ssl_ciphers"               => "EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA512:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EDH+aRSA:EECDH:!aNULL:!eNULL:!LOW:!RC4:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS",
  "ssl_session_cache"         => "shared:TLS:2m",
  "ssl_stapling"              => "on",
  "ssl_stapling_verify"       => "on",
  "resolver"                  => "8.8.4.4 8.8.8.8 valid=300s",
  "resolver_timeout"          => "10s"
}

default['mo_reverse_proxy']['use_upstream_repo'] = false #if true wi will install latest binary version from nginx site

default['mo_reverse_proxy']['log_formats']['custom'] = {
  'format' => '\'$server_name - $remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"\''
}


default['nginx']['default_site_enabled'] = false
default['nginx']['server_names_hash_bucket_size'] = 256
default['nginx']['server_tokens'] = 'off'
default['nginx']['client_max_body_size'] = '20m'
default['nginx']['client_body_buffer_size'] = '128k'
default['nginx']['log_dir'] = '/var/log/nginx-reverse-proxy'
