#
# Cookbook Name:: haproxy
#
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

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe "monitoring"

platform_options = node["haproxy"]["platform"]

if node["developer_mode"]
  node.set_unless["haproxy"]["admin_password"] = "password"
else
  node.set_unless["haproxy"]["admin_password"] = secure_password
end

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
  supports :status => true, :restart => true, :reload => true
  action [ :enable ]
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
  notifies :restart, resources(:service => "haproxy"), :immediately
end

monitoring_procmon "haproxy" do
  sname = platform_options["haproxy_service"]
  pname = platform_options["haproxy_process_name"]
  process_name pname
  script_name sname
end

monitoring_metric "haproxy" do
  type "proc"
  proc_name "haproxy"
  proc_regex platform_options["haproxy_service"]

  alarms(:failure_min => 1.0)
end

#### to add an individual service config:
#NOTE(mancdaz): move this into doc

#haproxy_configsingle "ec2-api" do
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

#haproxy_config "some-api" do
#  action :delete
#  notifies :restart, resources(:service => "haproxy"), :immediately
#end
