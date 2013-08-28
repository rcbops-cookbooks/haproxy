#
# Cookbook Name:: haproxy
# Resource:: virtual_server
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

actions :create, :delete

# In earlier versions of Chef the LWRP DSL doesn't support specifying
# a default action, so you need to drop into Ruby.
def initialize(*args)
  super
  @action = :create
end

attribute :vs_listen_ip, :kind_of => String, :required => true
attribute :vs_listen_port, :kind_of => String, :required => true
attribute :lb_algo, :kind_of => String,
  :equal_to => ["roundrobin", "leastconn", "source"], :default => "roundrobin"
attribute :real_servers, :kind_of => Array, :required => true
attribute :mode, :kind_of => String, :default => "http"
attribute :options, :kind_of => Array
attribute :active_backup, :kind_of => [TrueClass,FalseClass], :default => false
