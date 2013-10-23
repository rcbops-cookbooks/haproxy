name              "haproxy"
maintainer        "Rackspace US, Inc."
maintainer_email  "rcb-deploy@lists.rackspace.com"
license           "Apache 2.0"
description       "Installs and configures haproxy"
long_description  IO.read(File.join(File.dirname(__FILE__), "README.md"))
version           IO.read(File.join(File.dirname(__FILE__), "VERSION"))


%w{ amazon centos debian fedora oracle redhat scientific ubuntu }.each do |os|
  supports os
end

%w{ apt openssl osops-utils yum }.each do |dep|
  depends dep
end

recipe "haproxy::default",
  "Installs and configures haproxy for use in an Openstack deployment"

attribute "haproxy/admin_port",
  :description => "The haproxy admin port",
  :default => "8040"

attribute "haproxy/services/api/host",
  :description => "The haproxy api host",
  :default => ""
