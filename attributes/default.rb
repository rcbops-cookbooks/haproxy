default["haproxy"]["admin_port"] = 8040
default["haproxy"]["services"]["api"]["host"] = ""       # node_attribute

case platform
when "fedora", "redhat", "centos"
  default["haproxy"]["platform"] = {
    "haproxy_packages" => [ "haproxy" ],
    "haproxy_service" => "haproxy",
    "haproxy_process_name" => "haproxy",
    "service_bin" => "/sbin/service",
    "package_options" => ""
  }
when "ubuntu", "debian"
  default["haproxy"]["platform"] = {
    "haproxy_packages" => [ "haproxy" ],
    "haproxy_service" => "haproxy",
    "haproxy_process_name" => "haproxy",
    "service_bin" => "/usr/sbin/service",
    "package_options" => "--force-yes -o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-confdef'"
  }
end
