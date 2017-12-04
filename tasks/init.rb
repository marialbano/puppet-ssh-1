#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

def service(action, service_name)
  if service_name.nil?
    cmd_string = 'facter -p osfamily'
    _stdout, _stderr, _status = Open3.capture3(cmd_string)
    osfamily = stdout.strip
    service_name = if osfamily == 'RedHat'
                     'sshd'
                   else
                     'ssh'
                   end
  end
  cmd_string = "service #{service_name} #{action}"
  _stdout, _stderr, _status = Open3.capture3(cmd_string)
  raise Puppet::Error, stderr if status != 0
  { status: "#{action} successful" }
end

params = JSON.parse(STDIN.read)
action = params['action']
service_name = params['service_name']

begin
  result = service(action, service_name)
  puts result.to_json
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
