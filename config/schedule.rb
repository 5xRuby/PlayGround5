# frozen_string_literal: true

if @environment == 'production'
  # TODO: Read Capistrano configure to prevent hardcode
  set :job_template, "bash -l -c 'export PATH=/usr/local/ruby25/bin:/usr/local/bin:$PATH && :job'"
  job_type :runner,  'cd :path && bin/rails runner -e :environment ":task" :output'
end

# TODO: Ensure timezone is correct
every 1.day at: '0:00 am' do
  runner 'Proxmox::VM.all.map(&:reinitialize!)'
end
