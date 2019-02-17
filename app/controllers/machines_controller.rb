# frozen_string_literal: true

class MachinesController < ApplicationController
  before_action :authenticate_user!

  def index
    @machines = Proxmox::VM.all.sort_by(&:vmid)
  end

  def show
    @machine = Proxmox::VM.find(params[:id])
    @interfaces = @machine.network_interfaces
    @os = @machine.osinfo
  end

  def hold
    service = HoldVMService.new(params[:id], current_user)
    service.perform
    redirect_to machine_path(params[:id])
  end

  def release
    Proxmox::VM.find(params[:id])&.reinitialize!
    redirect_to machines_path
  end
end
