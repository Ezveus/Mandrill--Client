module Mandrill
    module Client
        class Users < Call
            def initialize(key)
                super(key)
            end

            def info
                launch('info')
            end

            def ping
                base_launch('ping').body
            end

            def ping2
                launch('ping2')
            end

            def senders
                launch('senders')
            end

            def rsrc_url
                'users'
            end
        end
    end
end
