# Lab 2 PR, Metrics Aggregator

require 'typhoeus'
require 'pry'
require 'json'
require 'csv'
require 'ox'
require './device.rb'

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
    responces << request
  end
  responces
end

url = "https://desolate-ravine-43301.herokuapp.com"
responces = []

loop do
  response      = Typhoeus.post(url)
  session_key   = response.headers["Session"]
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

devices = []
responces.each do |response|
  case response.response.headers["Content-Type"]
  when /csv/i
    CSV.parse(response.response.body).drop(1).each do |data|
      devices << Device.parse_csv(data)
    end
  when /json/i
    devices << Device.parse_json(JSON.parse(response.response.body))
  when /xml/i
    devices << Device.parse_xml(Ox.load(response.response.body, mode: :hash)[:device])
  else
    next
  end
end

["Temperature sensor", "Humidity sensor", "Motion sensor",
 "Alien Presence detector", "Dark Matter detector", "Unknown"].each do |category|
  puts "\n\t#{category}", ""
  devices.each do |device|
    if category == device.category
      device.show_values
    end
  end
end
