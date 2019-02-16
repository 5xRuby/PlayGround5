# frozen_string_literal: true

class MachinesController < ApplicationController
  before_action :authenticate_user!

  def index
    @machines = Proxmox::VM.all.sort_by(&:vmid)
  end

  def hold
    service = HoldVMService.new(params[:id], current_user)
    service.perform
    redirect_to machines_path
  end

  def release
    Proxmox::VM.find(params[:id])&.reinitialize!
    redirect_to machines_path
  end
end
