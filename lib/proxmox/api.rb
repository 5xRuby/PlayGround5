# frozen_string_literal: true

require 'net/http'

module Proxmox
  class API
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
      with_token = path != 'access/ticket'
      req = build_request(klass, uri, headers, params, with_token)
      start(uri, req, &block)
    end

    def start(uri, req, &_block)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE unless verify_ssl

      http.start do
        res = http.request(req)
        break yield res if block_given?

        Oj.load(res.body)&.with_indifferent_access
      end
    rescue Oj::ParseError
      {}
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
      case req
      when Net::HTTP::Get, Net::HTTP::Delete
        req.uri.query = URI.encode_www_form(params)
      else
        req['Content-Type'] = 'application/x-www-form-urlencoded'
        req['CSRFPreventionToken'] = @ticket&.csrf_token if with_token
        req.body = URI.encode_www_form(params)
      end
    end

    def preferences
      Rails.application.credentials.proxmox
    end
  end
end
