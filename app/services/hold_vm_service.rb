# frozen_string_literal: true

require 'timeout'

class HoldVMService
  attr_reader :vmid, :user

  def initialize(vmid, user)
    @vmid = vmid
    @user = user
  end

  def perform
    # rubocop:disable Style/ColonMethodCall
    Timeout::timeout(30) do
      vm = Proxmox::VM.find(@vmid)
      wait_task vm.reinitialize!
      wait_task vm.start!
      install(vm, @user.keys)
      true
    end
    # rubocop:enable Style/ColonMethodCall
  rescue Timeout::Error
    false
  end

  private

  def wait_task(id)
    # TODO: Use nodes/{node}/tasks/{upid}/status instead pull all tasks
    loop do
      tasks = Proxmox::Task.all
      break if tasks.find { |t| t.upid == id && t.status == 'OK' }
    end
  end

  def install(machine, keys)
    machine.install_authorized_keys(keys)
  rescue Proxmox::API::ServerError
    retry
  end
end
