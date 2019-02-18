# frozen_string_literal: true

# TODO: Ensure timezone is correct
every 1.day at: '0:00 am' do
  runner 'Proxmox::VM.all.map(&:reinitialize!)'
end
