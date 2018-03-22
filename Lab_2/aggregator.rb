# Lab 2 PR, Metrics Aggregator

require 'typhoeus'
require 'pry'
require 'json'

def check_responces(requests)
  responces = []

  requests.each do |request|
    if request.response.response_code >= 300
      if request.response.response_code >= 400
        puts "Client Error: " + request.response.response_headers.split("\r").first
      elsif request.response.response_code >= 500
        puts "Internal Server Error: " + request.response.response_headers.split("\r").first
      elsif request.response.response_code >= 300
        puts "Redirection: " + request.response.response_headers.split("\r").first
      end
      return []
    end
    responces << request.response.body
  end
  responces
end

url = "https://desolate-ravine-43301.herokuapp.com"

loop do
  response      = Typhoeus.post(url)
  session_key   = response.headers["Session"]
  session_key   = "jhueuewrdhfkjsadhfakjfd"
  response_body = JSON.parse(response.body)
  hydra         = Typhoeus::Hydra.hydra

  paths    = []
  requests = []
  response_body.each { |key|  paths << key['path'] }

  paths.each do |path|
    request = Typhoeus::Request.new(url + path,  method: :post, headers: { "Session" => session_key })
    hydra.queue(request)
    requests << request
  end
  hydra.run
  responces = check_responces(requests)
  break if !responces.empty?
end

responces  # Need to parse depending of type, and refactor the code
