# frozen_string_literal: true

module Proxmox
  class VM < Base
    class << self
      def all
        Proxmox::Node.all.map(&:vms).flatten
      end

      def find(id)
        id = id.to_i
        all.find { |vm| vm.vmid == id }
      end

      def where(params = {})
        return [] if params[:node].blank?

        Proxmox::Node
          .find(params[:node])
          .vms
          .select do |vm|
            params.reduce(true) do |prev, (k, v)|
              next true if k == :node

              prev & (vm.send(k) == v)
            end
          end
      end
    end

    attr_accessor :cpu, :diskwrite, :maxdisk, :maxmem, :cpus,
                  :mem, :pid, :template, :diskread, :vmid, :netin,
                  :status, :name, :netout, :disk, :uptime, :node

    alias id vmid

    def running?
      @status == 'running'
    end

    def start!
      Proxmox::API
        .post("nodes/#{node.name}/qemu/#{vmid}/status/start")
        .fetch(:data)
    end

    def stop!
      Proxmox::API
        .post("nodes/#{node.name}/qemu/#{vmid}/status/stop")
        .fetch(:data)
    end

    def shutdown!
      Proxmox::API
        .post("nodes/#{node.name}/qemu/#{vmid}/status/shutdown")
        .fetch(:data)
    end

    def reinitialize!
      Proxmox::API
        .post(
          "nodes/#{node.name}/qemu/#{vmid}" \
          '/snapshot/initialize_state/rollback'
        )
        .fetch(:data)
    end

    def authorized_keys
      Proxmox::API
        .get(
          "nodes/#{node.name}/qemu/#{vmid}/agent/file-read",
          file: '/root/.ssh/authorized_keys'
        )
        .dig(:data, :content)
        &.split("\n")
    end

    def install_authorized_keys(keys)
      keys = keys.join("\n") if keys.is_a?(Array)
      Proxmox::API
        .post(
          "nodes/#{node.name}/qemu/#{vmid}/agent/file-write",
          content: keys,
          file: '/root/.ssh/authorized_keys'
        )
        .fetch(:data)
    end

    def network_interfaces
      return [] unless running?

      Proxmox::API
        .get(
          "nodes/#{node.name}/qemu/#{vmid}" \
          '/agent/network-get-interfaces'
        )
        .dig(:data, :result) || []
    end

    def osinfo
      return {} unless running?

      Proxmox::API
        .get(
          "nodes/#{node.name}/qemu/#{vmid}" \
          '/agent/get-osinfo'
        )
        .dig(:data, :result) || {}
    end
  end
end
