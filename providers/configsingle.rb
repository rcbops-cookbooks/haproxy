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

action :create do

  servers = new_resource.servers

  r = template getPath do
  source "haproxy-new.cfg.erb"
  owner "root"
  group "root"
  mode "0644"
    variables(
      :name => new_resource.name,
      :listen => new_resource.listen,
      :servers => servers,
      :listen_port => new_resource.listen_port)
  end
  new_resource.updated_by_last_action(r.updated_by_last_action?)
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
