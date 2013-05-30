require 'net/http'
require 'json'
require "base64"

@host = 'localhost'
@port = '8081'
@path = "/api/v1/taxi_requests"



file = File.open("test_voice.m4a", "rb")
contents = file.read
s = Base64.encode64(contents)
@body ={
	taxi_request:{
		passenger_mobile: "15910676326",
		passenger_lat: "8",
		passenger_lng: "8",
		passenger_voice: s,
		waiting_time_range: 12,

	}
}.to_json


@request_header ={'Content-Type' =>'application/json',"Cookie" => "remember_token=z90ZZRYEsfc9_EtFzDWFIQ"}
request = Net::HTTP::Post.new(@path, initheader = @request_header )
request.body = @body
response = Net::HTTP.new(@host, @port).start {|http| http.request(request) }
puts "Response #{response.code} #{response.message}: #{response.body}"