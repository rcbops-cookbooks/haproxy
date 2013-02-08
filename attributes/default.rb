default["haproxy"]["admin_port"] = 8040
default["haproxy"]["services"]["api"]["host"] = ""       # node_attribute

default["openstack"]["services"] = [
  {
    "role" => "nova-api-os-compute",
    "namespace" => "nova",
    "service" => "api",
    "service_type" => "compute"
  },
  {
    "role" => "nova-api-ec2",
    "namespace" => "nova",
    "service" => "ec2-admin",
    "service_type" => "ec2"
  },
  {
    "role" => "nova-api-ec2",
    "namespace" => "nova",
    "service" => "ec2-public",
    "service_type" => "ec2"
  },
  {
    "role" => "keystone-api",
    "namespace" => "keystone",
    "service" => "admin-api",
    "service_type" => "identity"
  },
  {
    "role" => "keystone-api",
    "namespace" => "keystone",
    "service" => "service-api",
    "service_type" => "identity"
  },
  {
    "role" => "cinder-api",
    "namespace" => "cinder",
    "service" => "api",
    "service_type" => "volume"
  },
  {
    "role" => "glance-api",
    "namespace" => "glance",
    "service" => "api",
    "service_type" => "image"
  },
  {
    "role" => "swift-proxy-server",
    "namespace" => "swift",
    "service" => "proxy",
    "service_type" => "object-store"
  }
]

case platform
when "fedora", "redhat", "centos"
  default["haproxy"]["platform"] = {
    "haproxy_packages" => [ "haproxy" ],
    "haproxy_service" => "haproxy",
    "haproxy_process_name" => "haproxy",
    "package_options" => ""
  }
when "ubuntu", "debian"
  default["haproxy"]["platform"] = {
    "haproxy_packages" => [ "haproxy" ],
    "haproxy_service" => "haproxy",
    "haproxy_process_name" => "haproxy",
    "package_options" => "--force-yes -o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-confdef'"
  }
end
