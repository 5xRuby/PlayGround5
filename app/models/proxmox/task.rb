# frozen_string_literal: true

module Proxmox
  class Task < Base
    class << self
      def all
        Proxmox::API
          .get('cluster/tasks')
          .fetch(:data, [])
          .map { |task| Task.new(task) }
      end
    end

    attr_accessor :user, :id, :type, :endtime, :status, :upid,
                  :node, :starttime, :saved
  end
end
