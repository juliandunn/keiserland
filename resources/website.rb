# How to write a custom resource, Chef 12.5-style:
#
# Declare properties. Note how we're no longer calling these
# "attributes". Also, the type-checking and validation parameter syntax
# is much easier.
property :instance_name, String, name_property: true
property :port, Fixnum, required: true

# Declare what this provides -- optional. But, it allows you to now
# override the inferred name, which by default would be
# #{cookbook_name}_#{name_of_this_file_minus_dot_rb}
#
# It's also possible to say that this only provides "keisersite" on
# certain platforms, platform_family, platform_version, e.g.
# 
# provides :keisersite, platform_family: rhel, platform_version: 7

provides :keisersite

# Write your action(s).
# Note what we are avoiding versus pre-12.5:
# 
# * use_inline_resources or whyrun_supported?
# * having to know anything about new_resource object just to refer to properties
# * having to put the logic in the file in providers/ directory
action :create do
  package 'httpd' do
    action :install
  end

  template "/lib/systemd/system/httpd-#{instance_name}.service" do
    source "httpd.service.erb"
    variables(
      :instance_name => instance_name
    )
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end

  template "/etc/httpd/conf/httpd-#{instance_name}.conf" do
    source "httpd.conf.erb"
    variables(
      :instance_name => instance_name,
      :port => port
    )
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end

  directory "/var/www/vhosts/#{instance_name}" do
    mode '0755'
    recursive true
    owner 'root'
    group 'root'
    action :create
  end

  service "httpd-#{instance_name}" do
    action [:enable, :start]
  end
end
