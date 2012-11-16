default["haproxy"]["admin_port"] = 8080

default["openstack"]["services"] = {
  "nova-api" => {
    "role" => "nova-api-os-compute",
    "namespace" => "nova",
    "service" => "api"
  },
  "nova-ec2-admin" => {
    "role" => "nova-api-ec2",
    "namespace" => "nova",
    "service" => "ec2-admin"
  },
  "nova-ec2-public" => {
    "role" => "nova-api-ec2",
    "namespace" => "nova",
    "service" => "ec2-public"
  },
  "keystone-admin-api" => {
    "role" => "keystone",
    "namespace" => "keystone",
    "service" => "admin-api"
  },
  "keystone-service-api" => {
    "role" => "keystone",
    "namespace" => "keystone",
    "service" => "service-api"
  },
  "glance-api" => {
    "role" => "glance-api",
    "namespace" => "glance",
    "service" => "api"
  },
  "cinder-api" => {
    "role" => "cinder-api",
    "namespace" => "cinder",
    "service" => "volume"
  }
}

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
    "package_options" => "--force-yes -o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-confdef'"
  }
end
