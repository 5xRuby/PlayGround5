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
                  :status, :name, :netout, :disk, :uptime
  end
end
