require "json"
require "net/http"

module Mandrill
  module Client
    def self.ruby_version21?
        true if RUBY_VERSION.split('.')[0].to_i == 2 && RUBY_VERSION.split('.')[1].to_i >= 1
    end

    def self.boolean? o
        o == true || o == false
    end

    if ruby_version21?
        module Refinements
            refine Object do
                def blank?
                    respond_to?(:empty?) ? empty? : !self
                end
            end
        end
    end

    module Commons
        def to_hash
            h = {}
            instance_variables.each do |var|
                v = var.to_s.sub('@','')
                o = method(v).call
                o = o.to_hash if o.respond_to?(:to_hash)
                h[v.to_sym] = o
            end
            h
        end

        def to_json
            JSON.dump(to_hash)
        end
    end
  end
end

unless Mandrill::Client.ruby_version21?
    class Object
        def blank?
            respond_to?(:empty?) ? empty? : !self
        end
    end
end

require "mandrill/client/version"
require "mandrill/client/call"
require "mandrill/client/users"
require "mandrill/client/messages"
require "mandrill/client/mail"
