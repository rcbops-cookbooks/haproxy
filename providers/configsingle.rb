#
# Cookbook Name:: haproxy
# Provider:: configsingle
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
  Chef::Log.warn("haproxy_configsingle is deprecated" +
    " and will be removed in a future release")

  servers = new_resource.servers

  r = template get_path do
    cookbook "haproxy"
    source "haproxy-new.cfg.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :name => new_resource.name,
      :listen => new_resource.listen,
      :servers => servers.values.map do |value|
        value["host"] + ":" + value["port"]
      end,
      :listen_port => new_resource.listen_port)
  end
  new_resource.updated_by_last_action(r.updated_by_last_action?)
end


action :delete do
  Chef::Log.warn("haproxy_configsingle is deprecated" +
    " and will be removed in a future release")

  file get_path do
    action :delete
  end
  new_resource.updated_by_last_action(true)
end

private

def get_path
  return "/etc/haproxy/haproxy.d/#{new_resource.name}.cfg"
end
