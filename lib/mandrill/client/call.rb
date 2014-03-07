module Mandrill
    module Client
        ROOT_URL = 'https://mandrillapp.com/api/1.0'

        class Call
            def initialize(api_key, adress = ROOT_URL)
                @api_key = api_key
                @adress = adress
            end

            def send
                response = base_send
                begin
                    JSON.parse response.body
                rescue JSON::ParserError => error
                    { "status" => "error", "code" => -42, "name" => "JSON_Parser_Error", "message" => "#{error}" }
                end
            end

            def base_send
                uri = URI(url)

                request = Net::HTTP::Post.new uri
                request.body = to_json
                response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
                    rsp = http.request request
                end
            end

            def to_json
                "{\"key\":\"#{@api_key}\"}"
            end

            def url
                @adress + '/' + @rsrc_url + '/' + @url + '.json'
            end
        end
    end
end
