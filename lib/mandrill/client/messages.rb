module Mandrill
    module Client
        using Refinements if Client.ruby_version21?

        class Messages < Call
            attr_reader :message, :async, :ip_pool, :send_at

            def initialize(key)
                super(key)
            end

            def send(message, async = false, ip_pool = nil, send_at = nil)
                @message = message
                unless @message.errors.blank?
                    raise ArgumentError, "unvalid message"
                end
                @async = async if async
                @ip_pool = ip_pool unless ip_pool.blank?
                @send_at = send_at unless send_at.blank?
                launch('send')
            end

            def rsrc_url
                'messages'
            end
        end
    end
end
