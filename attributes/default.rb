default["haproxy"]["admin_port"] = 8080

default["openstack"]["services"] = [
  {
    "role" => "nova-api-os-compute",
    "namespace" => "nova",
    "service" => "api"
  },
  {
    "role" => "keystone",
    "namespace" => "keystone",
    "service" => "admin-api"
  },
  {
    "role" => "keystone",
    "namespace" => "keystone",
    "service" => "service-api"
  }
]

case platform
when "fedora", "redhat", "centos"
  default["haproxy"]["platform"] = {
    "haproxy_packages" => [ "haproxy" ],
    "haproxy_service" => "haproxy",
    "package_options" => ""
  }
when "ubuntu", "debian"
  default["haproxy"]["platform"] = {
    "haproxy_packages" => [ "haproxy" ],
    "haproxy_service" => "haproxy",
    "package_options" => "-o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-confdef'"
  }
end
