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


ks_admin_endpoint = get_access_endpoint("keystone", "keystone", "admin-api")
ks_service_endpoint = get_access_endpoint("keystone", "keystone", "service-api")
keystone = get_settings_by_role("keystone","keystone")
haproxy_ip = get_ip_for_net("public", "haproxy")


node['openstack']['services'].each do |svc|

  role = svc['role']
  service = svc['service']
  namespace = svc['namespace']
  service_type = svc['service_type']

  # fudgy for now to make the endpoint IP be this haproxy node ip
  # if we have not passed one in in the environment

  unless node[namespace]["services"][service].keys.include?("host")
    Chef::Log.info("setting #{namespace}:#{service} endpoint to #{haproxy_ip}")
    node.set[namespace]["services"][service]["host"] = haproxy_ip
  end

  if node[namespace]["services"][service].has_key? "host"

    # get the proper bind IPs
    case service_type
    when "ec2"
      public_endpoint = get_env_bind_endpoint("nova", "ec2-public")
      admin_endpoint = get_env_bind_endpoint("nova", "ec2-admin")
    when "identity"
      public_endpoint = get_env_bind_endpoint("keystone", "service-api")
      admin_endpoint = get_env_bind_endpoint("keystone", "admin-api")
    else
      public_endpoint = get_env_bind_endpoint(namespace, service)
      admin_endpoint = get_env_bind_endpoint(namespace, service)
    end

    keystone_register "Recreate Endpoint" do
      auth_host ks_admin_endpoint["host"]
      auth_port ks_admin_endpoint["port"]
      auth_protocol ks_admin_endpoint["scheme"]
      api_ver ks_admin_endpoint["path"]
      auth_token keystone["admin_token"]
      service_type service_type
      endpoint_region node["nova"]["compute"]["region"]
      endpoint_adminurl admin_endpoint["uri"]
      endpoint_internalurl public_endpoint["uri"]
      endpoint_publicurl public_endpoint["uri"]
      action :recreate_endpoint
    end

    # create the haproxy config files
    svc_name = [ svc['namespace'], svc['service'] ].join("-")
    haproxy_config svc_name do
      role role
      service service
      namespace namespace
      action :create
      notifies :reload, resources(:service => "haproxy"), :delayed
    end
  end
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
