require 'httparty'
require 'multi_json'
require 'net/http'
require 'hashie'
# require 'money'
# require 'monetize'
require 'time'
require 'securerandom'
require 'json'

# Branch Metrics API 
# ========================================== #

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

    BASE_URI = 'https://api.branch.io/v1'

    def initialize(app_id='', user_id=nil, identity=nil, data={})
      @app_id = app_id
      @user_id = user_id
    
      # defaults
      data[:base_uri] ||= BASE_URI
      @base_uri = data[:base_uri]
      data[:format] ||= :json
      data.each do |k,v|
        self.class.send k,v
      end
    end
# ========================================== #
# GET Requests #
# ========================================== #
# App, Credits, Credit History
 			
      # App - Get the current branch configuration
      def app data={}
        get '/app', data
      end

 			# Credit Count
 			def credits page=1, data={}
 			  get '/credits', data
   	  end

 			# Credit History
      def credit_history data={}
        get '/credithistory', data
      end

      # Structure Dynamic Deeplink
      def dynamic_deeplink data={}
        data[:base_uri] = "https://bnc.lt/"
        data[:format] ||= :json

        get '/a/', data
      end

      # Get Referral Code
      def referral data={}
        get '/referralcode', data
      end


# ========================================== #
# POST Requests
# ========================================== #
# app, url, event, eventresponse, referralcode, applycode, redeem

      # Create App Config
      def create_app app_name, dev_name, dev_email
        data[:app_name] = app_name
        data[:dev_name] = dev_name
        data[:dev_email] = dev_email
      end
      
      # Create Deeplink
      def create_deeplink data={}
        post '/url', data
      end

      # Redeem Credits
      def redeem amount, data={}
        data[:amount] = amount
        post '/redeem', data
      end

      # Create Remote Event for Funnels
      def create_event event, data={}
        data[:event] = event
        post '/event', data
      end

      # Create Dynamic Reward
      def dynamic_reward calculation_type, location, type, event, metadata, data={}
        data[:calculation_type] = calculation_type
        data[:location] = location
        data[:type] = type
        data[:event] = event
        data[:metadata] = metadata 

        post '/eventresponse', data
      end

      # Create Referral Code
      def create_referral amount, calculation_type, location, data={}
        data[:amount] = amount
        data[:calculation_type] = calculation_type
        data[:location] = location
        post '/referralcode', data
      end

      

# ========================================== #
# PUT Requests
# ========================================== #
      # Update App
      def update_app data={}
        put '/app', data
      end

# ========================================== #
# Wrappers for the main HTTP verbs
# ========================================== #

    def get(path, data={})
      http_verb :get, path, data
    end

    def post(path, data={})
      http_verb :post, path, data
    end

    def put(path, data={})
      http_verb :put, path, data
    end

    def delete(path, data={})
      http_verb :delete, path, data
    end

# ========================================== #
# White Listing Certification #
# ========================================== #

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

    def ssl_data
      { verify: true, cert_store: self.class.whitelisted_cert_store }
    end

    def http_verb(verb, path, data={})

      if [:get, :delete].include? verb
        request_data = {}
        path = "#{path}?#{URI.encode_www_form(data)}" if !data.empty?
      else
        request_data = {body: data.to_json}
      end

      headers = {
        'Content-Type' => "application/json",
        'app_id' => @app_id,
        'user_id' => @user_id,  
      }

      request_data[:headers] = headers

      r = self.class.send(verb, path, request_data.merge(ssl_data))
      hash = Hashie::Mash.new(JSON.parse(r.body))
      raise Error.new(hash.error) if hash.error
      raise Error.new(hash.errors.join(", ")) if hash.errors
      hash
    end

    class Error < StandardError; end

    private

  end
end

