#
# Cookbook Name:: openstack-haproxy
# w
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
  mode 0655
  owner "root"
  group "root"
end

cookbook_file "/etc/init.d/haproxy" do
  if platform?(%w{fedora redhat centos})
    source "haproxy-init-rhel"
  end
  if platform?(%w{ubuntu debian})
   source "haproxy-init-ubuntu"
  end

  mode 0655
  owner "root"
  group "root"
end

service "haproxy" do
  service_name platform_options["haproxy_service"]
  supports :status => true, :restart => true, :status => true, :reload => true
  action [ :enable, :start ]
end

#options = {}
#node["openstack"]["services"].each do |svc|
#  name = "#{svc.namespace}-#{svc.service}"
#  options[name] = {}
#  endpoint = get_access_endpoint(svc.role, svc.namespace, svc.service)
#  options[name]["listen_port"] = endpoint["port"]
#  server_list = get_realserver_endpoints(svc.role, svc.namespace, svc.service)
#  server_list.each do |server|
#    # Collect each server into the array
#    tmp_hash = {"host" => server["host"], "port" => server["port"]}
#    options[name]["servers"] << tmp_hash
#  end
#end

#options = {
#  "nova-api" => {
#    "listen_port" => "8774",
#    "servers" => {
#      {"name" => "foo1", "host" => "x.x.x.x", "port" => "8774"},
#      {"name" => "foo2", "host" => "y.y.y.y", "port" => "8774"}
#    }
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


# iterate through the services in the attributes file
# and create a config with all the discovered listening servers
node['openstack']['services'].each do |svc|
  servers = {}
  name = "#{svc['namespace']}-#{svc['service']}"
  endpoint = get_access_endpoint(svc['role'], svc['namespace'], svc['service'])
  listen_port = endpoint['port']
  server_list = get_realserver_endpoints(svc['role'], svc['namespace'], svc['service'])
  backend = 1
  server_list.each do |server|
    # push each server into the has
    servers["#{name}-#{backend}"] = {"host" => server["host"], "port" => server["port"]}
    backend += 1
  end


  # create the config file for this service
  oshaproxy_config "#{name}" do
    action :create
    servers servers
    listen "0.0.0.0"
    listen_port listen_port
    notifies :reload, resources(:service => "haproxy"), :immediately
  end
end

#### to add an individual service config:

#oshaproxy_config "ec2-api" do
#  action :create
#  servers(
#      "foo1" => {"host" => "1.2.3.4", "port" => "8774"},
#      "foo2" => {"host" => "5.6.7.8", "port" => "8774"}
#  )
#  listen "0.0.0.0"
#  listen_port "4568"
#  notifies :restart, resources(:service => "haproxy"), :immediately
#end

#### to delete an individual service config

#oshaproxy_config "some-api" do
#  action :delete
#  notifies :restart, resources(:service => "haproxy"), :immediately
#end
