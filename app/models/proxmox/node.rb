# frozen_string_literal: true

module Proxmox
  class Node < Base
    class << self
      def all
        Proxmox::API
          .get('nodes')
          .fetch(:data, [])
          .map { |node| Node.new(node) }
      end

      def find(id)
        all.find { |node| node.name == id }
      end
    end

    attr_accessor :uptime, :maxdisk, :node, :maxmem, :ssl_fingerprint,
                  :maxcpu, :level, :type, :id, :disk, :mem, :status, :cpu

    alias name node

    def vms
      Proxmox::API
        .get("nodes/#{name}/qemu")
        .fetch(:data, [])
        .map { |vm| VM.new(vm.merge(node: self)) }
    end
  end
end
