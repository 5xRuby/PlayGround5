# frozen_string_literal: true

class MachinesController < ApplicationController
  before_action :authenticate_user!

  def index
    @machines = Proxmox::VM.all.sort_by(&:vmid)
  end
end
