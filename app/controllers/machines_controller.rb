# frozen_string_literal: true

class MachinesController < ApplicationController
  def index
    @machines = Proxmox::VM.all.sort_by(&:vmid)
  end
end
