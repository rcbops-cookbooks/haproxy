maintainer        "Rackspace US, Inc."
license           "Apache 2.0"
description       "Installs and configures haproxy for use in an Openstack deployment"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0.0"

%w{ ubuntu }.each do |os|
  supports os
end

%w{ nova apt osops-utils yum keystone }.each do |dep|
  depends dep
end
