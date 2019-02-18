# frozen_string_literal: true

require 'proxmox/api'

Proxmox::API.ticket = Proxmox::Ticket.create(Proxmox::API.username, Proxmox::API.password)
