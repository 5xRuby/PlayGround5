# frozen_string_literal: true

module Proxmox
  class VM < Base
    class << self
      def all
        Proxmox::Node.all.map(&:vms).flatten
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

    def start!
      return if @status == 'running'

      Proxmox::API
        .post("nodes/#{node.name}/qemu/#{vmid}/status/start")
    end

    def stop!
      return if @status == 'stopped'

      Proxmox::API
        .post("nodes/#{node.name}/qemu/#{vmid}/status/stop")
    end

    def shutdown!
      return if @status == 'stopped'

      Proxmox::API
        .post("nodes/#{node.name}/qemu/#{vmid}/status/shutdown")
    end

    def reinitialize!
      Proxmox::API
        .post(
          "nodes/#{node.name}/qemu/#{vmid}" \
          '/snapshot/initialize_state/rollback'
        )
    end
  end
end
