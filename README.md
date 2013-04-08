Support
=======

Issues have been disabled for this repository.  
Any issues with this cookbook should be raised here:

[https://github.com/rcbops/chef-cookbooks/issues](https://github.com/rcbops/chef-cookbooks/issues)

Please title the issue as follows:

[haproxy]: \<short description of problem\>

In the issue description, please include a longer description of the issue, along with any relevant log/command/error output.  
If logfiles are extremely long, please place the relevant portion into the issue description, and link to a gist containing the entire logfile


Description
===========

Installs and configures haproxy for use in an Openstack deployment

http://haproxy.1wt.eu/

Requirements
============

Chef 0.10.0 or higher required (for Chef environment use)

Platform
--------

* CentOS >= 6.3
* Ubuntu >= 12.04

Cookbooks
---------

The following cookbooks are dependencies:

* apt
* monitoring
* openssl
* osops-utils
* yum

Resources/Providers
===================

Virtual Servers
---------------

### Example

    haproxy_virtual_server "web" do
      lb_algo        "leastconn"
      vs_listen_ip   "192.168.100.10"
      vs_listen_port "80"
      real_servers   [{"ip" => "192.168.100.11", "port" => "80"}, {"ip" => "192.168.100.12", "port" => "80}]
    end

`lb_algo` options are `roundrobin`, `leastconn`, defaults to `roundrobin`

Recipes
=======

default
-------

The default recipe will install haproxy with a generic haproxy.cfg configuration

Data Bags
=========

Attributes 
==========

* `haproxy["admin_port"]` - Admin port for haproxy statistics page
* `haproxy["admin_password"]` - Admin password for haproxy statistics page (defaults to `password` when `node["developer_mode"] = true`)

Templates
=========

* `haproxy.cfg.erb` - Config for haproxy server
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

Copyright 2012, Rackspace US, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
