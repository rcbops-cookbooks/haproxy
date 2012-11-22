#
# Cookbook Name:: haproxy
# Provider:: config
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
#

action :create do
  name = new_resource.name
  role = new_resource.role
  namespace = new_resource.namespace
  service = new_resource.service

  endpoint = get_access_endpoint(role, namespace, service)
  if not endpoint.nil?
    listen_port = endpoint['port']
    servers = {}
    server_list = get_realserver_endpoints(role, namespace, service)
    log(server_list)
    servers = server_list.each.inject([]) {|output, k| output << [k['host'],k['port']].join(":") }

    template getPath do
      source "haproxy-new.cfg.erb"
      owner "root"
      group "root"
      mode "0644"
      variables(
        :name => name,
        :listen => "0.0.0.0",
        :servers => servers,
        :listen_port => listen_port)
    end
    new_resource.updated_by_last_action(true)
  else
    new_resource.updated_by_last_action(false)
  end
end

action :delete do
  file getPath do
    action :delete
  end
  new_resource.updated_by_last_action(true)
end

private
def getPath
  return "/etc/haproxy/haproxy.d/#{new_resource.name}.cfg"
end
