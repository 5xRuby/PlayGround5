# frozen_string_literal: true

module Proxmox
  class Ticket < Base
    class << self
      def create(username, password, relam = :pve)
        params = {
          username: "#{username}@#{relam}",
          password: password
        }
        res = Proxmox::API.post('access/ticket', params)
        token = res.dig(:data, :ticket)
        csrf_token = res.dig(:data, :CSRFPreventionToken)
        Ticket.new(token: token, csrf_token: csrf_token, username: username)
      end
    end

    attr_accessor :token, :csrf_token, :username
  end
end
