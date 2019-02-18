# frozen_string_literal: true

set :job_template, "bash -l -c 'export PATH=/usr/local/ruby25/bin:$PATH && :job'" if @environment == 'production'

# TODO: Ensure timezone is correct
every 1.day at: '0:00 am' do
  runner 'Proxmox::VM.all.map(&:reinitialize!)'
end
