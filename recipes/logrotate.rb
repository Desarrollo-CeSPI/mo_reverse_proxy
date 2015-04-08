include_recipe "logrotate"

logrotate_app "mo-reverse-proxy" do
  path      node['nginx']['log_dir']
  options   %w(missingok delaycompress notifempty compress sharedscripts)
  frequency 'weekly'
  minsize   '1M'
  rotate    52
  create    %W(644 #{www_user} #{www_group}).join ' '
  postrotate "    [ -s #{nginx_pid} ] && kill -USR1 `cat #{nginx_pid}`"
end
