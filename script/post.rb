require 'net/http'
require 'json'
require "base64"
class TestApi
	#@host = 'localhost'
	def initialize
		@host = 'v2.365check.net'
		@port = '8081'
	end

	def create_taxi_request_api	
		cookie = JSON.parse(self.passenger_signin_api)
		path = "/api/v1/taxi_requests"
		file = File.open("test_voice.m4a", "rb")
		contents = file.read
		s = Base64.encode64(contents)
		body ={
			taxi_request:{
				passenger_mobile: "15910676326",
				passenger_lat: "8",
				passenger_lng: "8",
				passenger_voice: s,
				passenger_voice_format: 'm4a',
				waiting_time_range: 12,

			}
		}.to_json
		request_header ={'Content-Type' =>'application/json',"Cookie" => "remember_token=#{cookie[:token_value]}"}
		self.get_response(path,request_header,body)
	end

	def passenger_signin_api
		path = "/api/v1/sessions/passenger_signin"
		body = {session:{mobile:"15910676326",password:"8"}}.to_json
		request_header = {'Content-Type' =>'application/json'}
		self.get_response(path,request_header,body)
	end

	def get_response(path,header,body)
		request 		= Net::HTTP::Post.new(path, initheader = header )
		request.body 	= body
		response = Net::HTTP.new(@host, @port).start {|http| http.request(request) }
		puts "Response #{response.code} #{response.message}: #{response.body}"
		response.body
	end
end

s = TestApi.new
#s.passenger_signin_api
s.create_taxi_request_api



