require 'httparty'
require 'multi_json'
require 'net/http'
require 'hashie'
require 'money'
require 'monetize'
require 'time'
require 'securerandom'
require 'json'

# Branch Metrics API 
# ========================================== #
# API GET / POST / PUT Options

# GET /v1/app/ # Getting a new Branch app config
# GET /v1/credits
# GET /v1/credithistory

# POST /v1/app # Posting a new Branch app config
# POST /v1/url
# POST /v1/event
# POST /v1/eventresponse
# POST /v1/referralcode/
# POST /v1/applycode/
# POST /v1/redeem

# PUT /v1/app/ Update Branch app config
# ========================================== #
# api_url = "https://api.branch.io"

# ========================================== #  
# Required Data
# "Content-Type", "application/json")
# 'app_id', application_id)
# ========================================== #
# Optional Data to include in Data Dictionary
  # ('$og_title', og_title) 
  # ('$og_description', og_description)
  # ('$og_image_url', og_image_url)
  # ('$og_video', og_video)
  # ('$og_url', og_url)
  # ('$og_app_id', og_app_id)
  # ('$desktop_url', desktop_url)
  # ('$android_url', android_url)
  # ('$ios_url', ios_url)
  # ('$ipad_url', ipad_url)
  # ('$fire_url', fire_url)
  # ('$blackberry_url', blackberry_url)
  # ('$windows_phone_url', windows_phone_url)
# ========================================== #
# Other Optional Tracking fields
# Identity
# Tags
# Campaign
# Feature
# Channel
# Stage
# ========================================== #

module Branch
		class Client
    include HTTParty

    BASE_URI = 'https://api.branch.io/'

    def initialize(api_key='', app_id='', options={})
      @api_key = api_key
      @app_id = app_id

      #defaults
      options[:base_uri] ||= BASE_URI
      @base_uri = options[:base_uri]
      options[:format] ||= :json
      options.each do |k,v|
        self.class.send k,v
      end
    end

 			# Apps

 			# Credits
 			def credits page=1, options={}
 			 r = get '/credits', {page: page}.merge(options)
      r.credits ||= []
      r
   	end


 			# Credit History


				# Wrappers for the main HTTP verbs

    def get(path, options={})
      http_verb :get, path, options
    end

    def post(path, options={})
      http_verb :post, path, options
    end

    def put(path, options={})
      http_verb :put, path, options
    end

    def delete(path, options={})
      http_verb :delete, path, options
    end

    def self.whitelisted_cert_store
      @@cert_store ||= build_whitelisted_cert_store
    end

    def self.build_whitelisted_cert_store
      path = File.expand_path(File.join(File.dirname(__FILE__), 'ca-branch.crt'))

      certs = [ [] ]
      File.readlines(path).each{|line|
        next if ["\n","#"].include?(line[0])
        certs.last << line
        certs << [] if line == "-----END CERTIFICATE-----\n"
      }

      result = OpenSSL::X509::Store.new

      certs.each{|lines|
        next if lines.empty?
        cert = OpenSSL::X509::Certificate.new(lines.join)
        result.add_cert(cert)
      }

      result
    end

    def ssl_options
      { verify: true, cert_store: self.class.whitelisted_cert_store }
    end

    def http_verb(verb, path, options={})

      if [:get, :delete].include? verb
        request_options = {}
        path = "#{path}?#{URI.encode_www_form(options)}" if !options.empty?
      else
        request_options = {body: options.to_json}
      end

      headers = {
        'api_keyY' => @api_key,
        'app_id' => @app_id,
        "Content-Type" => "application/json",
      }

      request_options[:headers] = headers

      r = self.class.send(verb, path, request_options.merge(ssl_options))
      hash = Hashie::Mash.new(JSON.parse(r.body))
      raise Error.new(hash.error) if hash.error
      raise Error.new(hash.errors.join(", ")) if hash.errors
      hash
    end

    class Error < StandardError; end

    private

  end
end

