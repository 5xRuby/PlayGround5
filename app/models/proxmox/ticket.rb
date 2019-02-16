# frozen_string_literal: true

require_dependency 'proxmox/api'

module Proxmox
  class Ticket
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

    attr_reader :token, :csrf_token, :username

    def initialize(params = {})
      params.each do |k, v|
        instance_variable_set(:"@#{k}", v)
      end
    end
  end
end
