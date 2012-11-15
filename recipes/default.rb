#
# Cookbook Name:: openstack-haproxy
# Recipe:: default
#
# Copyright 2012, Rackspace US, Inc.
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

platform_options = node["haproxy"]["platform"]

platform_options["haproxy_packages"].each do |pkg|
  package pkg do
    action :upgrade
    options platform_options["package_options"]
  end
end

template "/etc/default/haproxy" do
  source "haproxy-default.erb"
  owner "root"
  group "root"
  mode 0644
  only_if { platform?("ubuntu","debian") }
end

directory "/etc/haproxy/haproxy.d" do
  mode 600
  owner root
  group root
end

cookbook_file "/etc/init.d/haproxy" do
  if platform?(%w{fedora redhat centos})
    source "haproxy-init-rhel"
  if platform?(%w{ubuntu debian})
   source "haproxy-init-ubuntu"
  end

  mode 0644
  owner root
  group root
end

service "haproxy" do
  service_name platform_options["haproxy_service"]
  supports :status => true, :restart => true, :status => true, :reload => true
  action [ :enable, :start ]
end

options = {}
node["openstack"]["services"].each do |svc|
  name = "#{svc.namespace}-#{svc.service}"
  options[name] = {}
  endpoint = get_access_endpoint(svc.role, svc.namespace, svc.service)
  options[name]["listen_port"] = endpoint["port"]
  server_list = get_realserver_endpoints(svc.role, svc.namespace, svc.service)
  server_list.each do |server|
    # Collect each server into the array
    tmp_hash = {"host" => server["host"], "port" => server["port"]}
    options[name]["servers"] << tmp_hash
  end
end

#options = {
#  "nova-api" => {
#    "listen_port" => "8774",
#    "servers" => [
#      {"name" => "foo1", "host": "x.x.x.x", "port" => "8774"},
#      {"name" => "foo2", "host": "y.y.y.y", "port" => "8774"}
#    ]
#  }
#}

template "/etc/haproxy/haproxy.cfg" do
  source "haproxy.cfg.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
    "admin_port" => node["haproxy"]["admin_port"]
  )
  notifies :restart, resources(:service => "haproxy"), :immediately
end
