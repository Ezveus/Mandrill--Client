module Mandrill
    module Client
        ROOT_URL = 'https://mandrillapp.com/api/1.0'

        class Call
            include Commons
            attr_reader :key

            def initialize(key)
                @key = key
            end

            def launch(method)
                response = base_launch(method)
                begin
                    JSON.parse(response.body)
                rescue JSON::ParserError => error
                    { "status" => "error", "code" => -42, "name" => "JSON_Parser_Error", "message" => "#{error}" }
                end
            end

            def base_launch(method)
                uri = URI(url(method))

                request = Net::HTTP::Post.new(uri.to_s)
                request.body = to_json
                response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
                    rsp = http.request(request)
                end
            end

            def url(method)
                ROOT_URL + '/' + rsrc_url + '/' + method + '.json'
            end
        end
    end
end
