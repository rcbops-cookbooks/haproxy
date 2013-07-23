#
# Cookbook Name:: haproxy_test
# Recipe:: default
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

require_relative "./support/helpers"

describe_recipe "haproxy_test::default" do
  include HAProxyTestHelpers

  describe "creates a haproxy configuration file" do
    let(:config) { file(::File.join("/etc/haproxy/haproxy.cfg")) }

    it { config.must_exist }
  end

  describe "runs the application as a service" do
    it { service("haproxy").must_be_enabled }
    it { service("haproxy").must_be_running }
  end

  it "create an init config default file on debian platforms" do
    skip "Debian family only test" unless node.platform_family?("debian")

    file("/etc/default/haproxy").must_exist
  end

  it "does not create init config default file on non debian platforms" do
    skip "Rhel family only test" unless node.platform_family?("rhel")

    file("/etc/default/haproxy").wont_exist
  end
end
