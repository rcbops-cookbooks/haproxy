name             "haproxy_test"
maintainer       "Rackspace US, Inc"
maintainer_email "rcb-deploy@lists.rackspace.com"
license          "Apache 2.0"
description      "Installs and configures haproxy_test"
version          "0.0.1"

%w{ amazon centos debian fedora oracle redhat scientific ubuntu }.each do |os|
  supports os
end

%w{ haproxy }.each do |dep|
  depends dep
end
