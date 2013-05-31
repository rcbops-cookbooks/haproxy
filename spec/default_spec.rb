require "spec_helper"

describe "haproxy::default" do
  let(:chef_run) { runner.converge "haproxy_test::default" }
  let(:node) { runner.node }
  let(:platform) { { :platform => "ubuntu", :version => "12.04" } }
  let(:results) { [] }
  let(:runner) { ChefSpec::ChefRunner.new(runner_options) }
  let(:runner_options) do
    {
      :cookbook_path => [COOKBOOK_PATH],
      :evaluate_guards => true,
      :step_into => step_into
    }.merge(platform)
  end
  let(:step_into) { [] }

  before do
    Chef::Search::Query.any_instance.
      stub(:search).
      and_return([results, nil, nil])
  end

  context "admin_password" do
    it "is 'password' if developer_mode attribute is true" do
      node.set["developer_mode"] = true

      chef_run.node["haproxy"]["admin_password"].should eq "password"
    end

    it "uses admin_password attribute from other haproxies" do
      result = Chef::Node.new
      result.set["name"] = "existing_haproxy"
      result.set["haproxy"]["admin_password"] = "rolepassword"
      results << result

      chef_run.node["haproxy"]["admin_password"].should eq "rolepassword"
    end

    it "generates a password using openssl if no haproxy password exists" do
      Chef::Recipe.any_instance.
        should_receive(:secure_password).
        and_return("generatedpassword")

      chef_run.node["haproxy"]["admin_password"].should eq "generatedpassword"
    end

    it "uses nodes admin_password attribute if set" do
      node.set["haproxy"]["admin_password"] = "nodepassword"

      chef_run.node["haproxy"]["admin_password"].should eq "nodepassword"
    end
  end

  it "installs the packages in haproxy_packages attribute" do
    chef_run

    node["haproxy"]["platform"]["haproxy_packages"].each do |package|
      chef_run.should install_package(package)
      chef_run.package(package).options.should ==
        node["haproxy"]["platform"]["package_options"]
    end
  end

  it "drops haproxy upstart defaults on debian platforms" do
    chef_run.should create_file("/etc/default/haproxy")
  end

  context "on rhel platform" do
    let(:platform) { { :platform => "centos", :version => "6.3" } }

    it "skips haproxy upstart defaults on other platforms" do
      chef_run.should_not create_file("/etc/default/haproxy")
    end
  end

  it "creates an haproxy.d directory" do
    chef_run.should create_directory("/etc/haproxy/haproxy.d")
  end

  context "on debian platform" do
    it "creates an init.d script" do
      chef_run.should create_cookbook_file("/etc/init.d/haproxy")
      chef_run.cookbook_file("/etc/init.d/haproxy").source.should ==
        "haproxy-init-ubuntu"
    end
  end

  context "on rhel platform" do
    let(:platform) { { :platform => "centos", :version => "6.3" } }

    it "creates an init.d script" do
      chef_run.should create_cookbook_file("/etc/init.d/haproxy")
      chef_run.cookbook_file("/etc/init.d/haproxy").source.should ==
        "haproxy-init-rhel"
    end
  end

  it "configures service to start" do
    chef_run.should set_service_to_start_on_boot(
      node["haproxy"]["platform"]["haproxy_service"])
  end

  it "creates the haproxy config file" do
    chef_run.should create_file("/etc/haproxy/haproxy.cfg")
    chef_run.template("/etc/haproxy/haproxy.cfg").variables.should == {
      "admin_port" => node["haproxy"]["admin_port"],
      "admin_password" => node["haproxy"]["admin_password"]
    }
  end

  describe "haproxy_test::virtual_server_provider_create" do
    let(:chef_run) do
      runner.converge "haproxy_test::virtual_server_provider_create"
    end
    let(:step_into) { ["haproxy_virtual_server"] }
    let(:config) { "/etc/haproxy/haproxy.d/vs_myserver.cfg" }

    it "creates a virtual server file in haproxy.d" do
      chef_run.should create_file(config)
      chef_run.should create_file_with_content config,
        "listen myserver 127.0.0.1:8080"
      chef_run.should create_file_with_content config,
        "mode https"
      chef_run.should create_file_with_content config,
        "balance leastconn"
      chef_run.should create_file_with_content config,
        "option a"
      chef_run.should create_file_with_content config,
        "option b"
      chef_run.should create_file_with_content config,
        "server myserver-1 10.10.10.10 check"
      chef_run.should create_file_with_content config,
        "server myserver-2 10.10.10.11 check"
    end
  end

  describe "haproxy_test::config_provider_create" do
    let(:chef_run) { runner.converge "haproxy_test::config_provider_create" }
    let(:endpoint) { { "port" => "8080" } }
    let(:servers) do
      [
        { "host" => "10.10.10.10", "port" => "8080" },
        { "host" => "10.10.10.11", "port" => "8181" }
      ]
    end
    let(:step_into) { ["haproxy_config"] }
    let(:config) { "/etc/haproxy/haproxy.d/createconfig.cfg" }

    it "creates a config file in haproxy.d" do
      Chef::Provider.any_instance.
        should_receive(:get_access_endpoint).
        with("myrole", "mynamespace", "myservice").
        and_return(endpoint)

      Chef::Provider.any_instance.
        should_receive(:get_realserver_endpoints).
        with("myrole", "mynamespace", "myservice").
        and_return(servers)

      Chef::Log.should_receive(:warn).with(/haproxy_config is deprecated/)

      chef_run.should create_file(config)
      chef_run.should create_file_with_content config,
        "listen createconfig 0.0.0.0:8080"
      chef_run.should create_file_with_content config,
        "server createconfig-1 10.10.10.10:8080 check"
      chef_run.should create_file_with_content config,
        "server createconfig-2 10.10.10.11:8181 check"
    end
  end

  describe "haproxy_test::config_provider_delete" do
    let(:chef_run) { runner.converge "haproxy_test::config_provider_delete" }
    let(:step_into) { ["haproxy_config"] }

    it "deletes a config file from haproxy.d" do
      Chef::Log.should_receive(:warn).with(/haproxy_config is deprecated/)

      chef_run.should delete_file("/etc/haproxy/haproxy.d/deleteconfig.cfg")
    end
  end

  describe "haproxy_test::configsingle_provider_create" do
    let(:chef_run) do
      runner.converge "haproxy_test::configsingle_provider_create"
    end
    let(:step_into) { ["haproxy_configsingle"] }
    let(:config) { "/etc/haproxy/haproxy.d/createconfig.cfg" }

    it "creates a config file in haproxy.d" do
      Chef::Log.should_receive(:warn).with(/haproxy_configsingle is deprecated/)

      chef_run.should create_file(config)
      chef_run.should create_file_with_content config,
        "listen createconfig 127.0.0.1:8080"
      chef_run.should create_file_with_content config,
        "server createconfig-1 10.10.10.10:8080 check"
      chef_run.should create_file_with_content config,
        "server createconfig-2 10.10.10.11:8181 check"
    end
  end

  describe "haproxy_test::configsingle_provider_delete" do
    let(:chef_run) do
      runner.converge "haproxy_test::configsingle_provider_delete"
    end
    let(:step_into) { ["haproxy_configsingle"] }

    it "deletes a config file from haproxy.d" do
      Chef::Log.should_receive(:warn).with(/haproxy_configsingle is deprecated/)

      chef_run.should delete_file("/etc/haproxy/haproxy.d/deleteconfig.cfg")
    end
  end
end
