Support
=======

Issues have been disabled for this repository.  
Any issues with this cookbook should be raised here:

[https://github.com/rcbops/chef-cookbooks/issues](https://github.com/rcbops/chef-cookbooks/issues)

Please title the issue as follows:

[haproxy]: \<short description of problem\>

In the issue description, please include a longer description of the issue, along with any relevant log/command/error output.  
If logfiles are extremely long, please place the relevant portion into the issue description, and link to a gist containing the entire logfile

Please see the [contribution guidelines](CONTRIBUTING.md) for more information about contributing to this cookbook.

Description
===========

Installs and configures haproxy for use in an Openstack deployment

http://haproxy.1wt.eu/

Requirements
============

Chef 11.0 or higher required (for Chef environment use).

Platforms
---------

This cookbook is actively tested on the following platforms/versions:

* Ubuntu-12.04
* CentOS-6.3

While not actively tested, this cookbook should also work the following platforms:

* Debian/Mint derivitives
* Amazon/Oracle/Scientific/RHEL

Cookbooks
---------

The following cookbooks are dependencies:

* apt
* openssl
* osops-utils
* yum

Resources/Providers
===================

virtual_server
---------------

Example:

    haproxy_virtual_server "web" do
      lb_algo        "leastconn"
      vs_listen_ip   "192.168.100.10"
      vs_listen_port "80"
      real_servers   [{"ip" => "192.168.100.11", "port" => "80"}, {"ip" => "192.168.100.12", "port" => "80}]
    end

`lb_algo` options are `roundrobin`, `leastconn`, `source`, defaults to `roundrobin`

configsingle
------------

Example:

    haproxy_configsingle "ec2-api" do
      action :create
      servers(
        "foo1" => {"host" => "1.2.3.4", "port" => "8774"},
        "foo2" => {"host" => "5.6.7.8", "port" => "8774"}
      )
      listen "0.0.0.0"
      listen_port "4568"
      notifies :restart, resources(:service => "haproxy"), :immediately
    end

config
------

Example:

    haproxy_config "api" do
      role "myrole"
      namespace "mynamespace"
      service "myservice"
    end


    # delete a config from haproxy.d
    haproxy_config "some-api" do
      action :delete
      notifies :restart, resources(:service => "haproxy"), :immediately
    end


Recipes
=======

default
-------

The default recipe will install haproxy with a generic haproxy.cfg configuration

Attributes 
==========

* `haproxy["admin_port"]` - Admin port for haproxy statistics page
* `haproxy["admin_password"]` - Admin password for haproxy statistics page (defaults to `password` when `node["developer_mode"] = true`)

Templates
=========

* `haproxy.cfg.erb` - Config for haproxy server
* `haproxy-default.cfg.erb` - Config for upstart/init defaults on debian family
* `haproxy-new.cfg.erb` - Config for haproxy.d configurations
* `vs_generic.cfg.erb` - Config for virtual servers

License and Author
==================

Author:: Justin Shepherd (<justin.shepherd@rackspace.com>)  
Author:: Jason Cannavale (<jason.cannavale@rackspace.com>)  
Author:: Ron Pedde (<ron.pedde@rackspace.com>)  
Author:: Joseph Breu (<joseph.breu@rackspace.com>)  
Author:: William Kelly (<william.kelly@RACKSPACE.COM>)  
Author:: Darren Birkett (<Darren.Birkett@rackspace.co.uk>)  
Author:: Evan Callicoat (<evan.callicoat@RACKSPACE.COM>)  
Author:: Matt Thompson (<matt.thompson@rackspace.co.uk>)  
Author:: Chris Laco (<chris.laco@rackspace.com>)

Copyright 2012-2013, Rackspace US, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
