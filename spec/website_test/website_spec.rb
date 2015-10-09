require 'spec_helper'

describe 'website resource on CentOS 7' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos',
      version: '7.0',
      step_into: ['keisersite']
    ).converge('keiserland_test::default')
  end

  it 'creates the systemd unit file' do
    expect(chef_run).to create_template("/lib/systemd/system/httpd-example.service")
  end
end
