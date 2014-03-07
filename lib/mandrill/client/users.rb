module Mandrill
    module Client
        class Users < Call
            def initialize(api_key, adress = ROOT_URL)
                super(api_key, adress)
                @rsrc_url = 'users'
            end

            def info
                @url = "info"
                send
            end

            def ping
                @url = "ping"
                base_send.body
            end

            def ping2
                @url = "ping2"
                send
            end

            def senders
                @url = "senders"
                send
            end
        end
    end
end
