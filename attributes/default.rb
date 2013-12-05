#
# Cookbook Name:: haproxy
# Attributes:: default
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

default["haproxy"]["admin_port"] = 8040
default["haproxy"]["services"]["api"]["host"] = ""       # node_attribute

if platform_family?("rhel")
  default["haproxy"]["platform"] = {
    "haproxy_packages" => ["haproxy"],
    "haproxy_service" => "haproxy",
    "haproxy_process_name" => '^/usr/sbin/haproxy\b',
    "service_bin" => "/sbin/service",
    "package_options" => ""
  }
elsif platform_family?("debian")
  default["haproxy"]["platform"] = {
    "haproxy_packages" => ["haproxy"],
    "haproxy_service" => "haproxy",
    "haproxy_process_name" => '^/usr/sbin/haproxy\b',
    "service_bin" => "/usr/sbin/service",
    "package_options" => "--force-yes" +
      " -o Dpkg::Options::='--force-confold'" +
      " -o Dpkg::Options::='--force-confdef'"
  }
end
