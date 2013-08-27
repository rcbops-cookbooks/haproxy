#
# Cookbook Name:: haproxy
# Provider:: virtual_server
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
  name = new_resource.name.match('ec2') ? "ec2-api" : new_resource.name

  r = template "/etc/haproxy/haproxy.d/vs_#{name}.cfg" do
    source "vs_generic.cfg.erb"
    cookbook "haproxy"
    owner "root"
    group "root"
    mode "0644"
    variables(
      "name" => name,
      "vs_listen_ip" => new_resource.vs_listen_ip,
      "vs_listen_port" => new_resource.vs_listen_port,
      "lb_algo" => new_resource.lb_algo,
      "mode" => new_resource.mode,
      "real_servers" => new_resource.real_servers,
      "active_backup" => new_resource.active_backup,
      "options" => new_resource.options
    )
    notifies :restart, "service[haproxy]", :delayed
  end
  new_resource.updated_by_last_action(r.updated_by_last_action?)
end
