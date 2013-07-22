#
# Cookbook Name:: haproxy
# Recipe:: default
#
# Copyright 2012-2013, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

platform_options = node["haproxy"]["platform"]

if node["developer_mode"] == true
  password = 'password'
else
  haproxy_nodes =
    get_settings_by_role('openstack-ha', 'haproxy', includeme = false)

  begin
    password = haproxy_nodes['admin_password']
  rescue NoMethodError
    password = secure_password
  end
end

node.set_unless["haproxy"]["admin_password"] = password

platform_options["haproxy_packages"].each do |pkg|
  package pkg do
    action :install
    options platform_options["package_options"]
  end
end

template "/etc/default/haproxy" do
  source "haproxy-default.erb"
  owner "root"
  group "root"
  mode 0644
  only_if { platform_family?("debian") }
end

directory "/etc/haproxy/haproxy.d" do
  mode 0655
  owner "root"
  group "root"
end

cookbook_file "/etc/init.d/haproxy" do
  if platform_family?("rhel")
    source "haproxy-init-rhel"
  end
  if platform_family?("debian")
    source "haproxy-init-ubuntu"
  end

  mode 0655
  owner "root"
  group "root"
end

service "haproxy" do
  service_name platform_options["haproxy_service"]
  supports :status => true, :restart => true, :reload => true
  action [:enable]
  retries 5
  retry_delay 5
end

template "/etc/haproxy/haproxy.cfg" do
  source "haproxy.cfg.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
    "admin_port"     => node["haproxy"]["admin_port"],
    "admin_password" => node["haproxy"]["admin_password"]
  )
  notifies :restart, "service[haproxy]", :immediately
end
