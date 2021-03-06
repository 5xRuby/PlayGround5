# frozen_string_literal: true

require 'net/http'

module Proxmox
  class API
    class AuthorizationError < RuntimeError; end
    class ServerError < RuntimeError; end

    class << self
      delegate :respond_to_missing?, to: :instance

      # rubocop:disable Style/MissingRespondToMissing
      def method_missing(name, *args, &block)
        return instance.send(name, *args, &block) if instance.respond_to?(name)

        super
      end
      # rubocop:enable Style/MissingRespondToMissing
    end

    include Singleton

    attr_reader :cluster, :username, :password, :verify_ssl
    attr_accessor :ticket

    def initialize
      @cluster = preferences[:cluster]
      @username = preferences[:username]
      @password = preferences[:password]
      @verify_ssl = if preferences[:verify_ssl].nil?
                      true
                    else
                      preferences[:verify_ssl]
                    end
      @retires = 0
    end

    def endpoint(path)
      URI("#{@cluster}/api2/json/#{path}")
    end

    %w[get post put delete'].each do |method|
      define_method method do |path, headers = {}, params = nil, &block|
        request(method.titleize, path, headers, params, &block)
      end
    end

    protected

    def request(method, path, headers, params, &block)
      klass = Net::HTTP.const_get(method)
      uri = endpoint(path)
      uri.query = URI.encode_www_form(params || headers)
      req = build_request(klass, uri, headers, params, path != 'access/ticket')
      start(uri, req, &block)
    rescue AuthorizationError
      raise if @retires >= 3

      @retires += 1
      @ticket = Proxmox::Ticket.create(@username, @password)
      retry
    end

    def start(uri, req, &block)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE unless verify_ssl

      # TODO: Handling failed API request
      http.start do
        res = http.request(req)
        handle_response(res, &block)
      end
    end

    def handle_response(res, &_block)
      check_invalid_response(res)
      @retries = 0
      return yield res if block_given?

      Oj.load(res.body)&.with_indifferent_access || {}
    rescue Oj::ParseError
      {}
    end

    def check_invalid_response(res)
      code = res.code.to_i
      raise AuthorizationError if code == 401
      raise ServerError, res.message if code >= 500 && code < 600
    end

    def build_request(klass, uri, headers, params, with_token)
      req = klass.new(uri)
      headers.each { |k, v| req[k] = v } if params.present?
      params ||= headers
      req['Cookie'] = "PVEAuthCookie=#{@ticket&.token}" if with_token
      set_body(req, params, with_token)
      req
    end

    def set_body(req, params, with_token)
      return if req.is_a?(Net::HTTP::Get)
      return if req.is_a?(Net::HTTP::Delete)

      req['Content-Type'] = 'application/x-www-form-urlencoded'
      req['CSRFPreventionToken'] = @ticket&.csrf_token if with_token
      req.body = URI.encode_www_form(params)
    end

    def preferences
      Rails.application.credentials.proxmox
    end
  end
end
