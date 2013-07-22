#
# Cookbook Name:: haproxy
# Provider:: config
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

action :create do
  Chef::Log.warn(
    "haproxy_config is deprecated and will be removed in a future release")

  if new_resource.service == "ec2-admin" or new_resource.service == "ec2-public"
    name = "ec2-api"
  else
    name = new_resource.name
  end

  role = new_resource.role
  namespace = new_resource.namespace
  service = new_resource.service

  endpoint = get_access_endpoint(role, namespace, service)
  Chef::Log.debug("endpoint contains: #{endpoint}")
  if not endpoint.nil?
    listen_port = endpoint['port']
    servers = {}
    server_list = get_realserver_endpoints(role, namespace, service)
    log(server_list)
    servers = server_list.each.inject([]) do |output, k|
      output << [k['host'], k['port']].join(":")
    end

    r = template get_path do
      source "haproxy-new.cfg.erb"
      cookbook "haproxy"
      owner "root"
      group "root"
      mode "0644"
      variables(
        :name => name,
        :listen => "0.0.0.0",
        :servers => servers,
        :listen_port => listen_port)
    end
    new_resource.updated_by_last_action(r.updated_by_last_action?)
  else
    new_resource.updated_by_last_action(false)
  end
end

action :delete do
  Chef::Log.warn(
    "haproxy_config is deprecated and will be removed in a future release")

  file get_path do
    action :delete
  end
  new_resource.updated_by_last_action(true)
end

private

def get_path
  if new_resource.service == "ec2-admin" or new_resource.service == "ec2-public"
    return "/etc/haproxy/haproxy.d/ec2-api.cfg"
  else
    return "/etc/haproxy/haproxy.d/#{new_resource.name}.cfg"
  end
end
