require 'net/http'
require 'json'
require "base64"
class TestApi
	def initialize
		@host = 'localhost'
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
		request_header ={'Content-Type' =>'application/json',"Cookie" => "remember_token=#{cookie["token_value"]}"}
		self.post_request(path,request_header,body)
	end

	def show_taxi_request_api
		request_header 	= self.get_driver_head
		taxi_request   = JSON.parse(self.create_taxi_request_api)
		path 			= "/api/v1/taxi_requests/#{taxi_request["id"]}"
		#path 			= "/api/v1/taxi_requests/31	"
		self.get_request(path,request_header)
	end
	def answer_taxi_request_api(taxi_request=nil)
		request_header = self.get_driver_head
		taxi_request   ||= JSON.parse(self.create_taxi_request_api)
		path           = "/api/v1/taxi_requests/#{taxi_request["id"]}/response"
		#path           = "/api/v1/taxi_requests/45/response"
		body 		   ={
			taxi_response:{
				driver_mobile:"15910676326",
				driver_lat:"8",
				driver_lng:"8"
			}
		}.to_json
		self.post_request(path,request_header,body)
	end
	def confirm_taxi_request_api
		request_header = self.get_passenger_head
		taxi_request   = JSON.parse(self.create_taxi_request_api)
		answer_taxi_request_api(taxi_request)
		path 		   = "/api/v1/taxi_requests/#{taxi_request["id"]}/confirm"
		self.post_request(path,request_header,nil)
	end
	def cancel_taxi_request_api
		taxi_request  = JSON.parse(self.create_taxi_request_api)
		request_header = self.get_passenger_head
		path 		   = "/api/v1/taxi_requests/#{taxi_request["id"]}/cancel"
		self.post_request(path,request_header,nil)
	end
	def create_driver_track_point_api
		path = "/api/v1/driver_track_points"
		cookie = JSON.parse(self.driver_signin_api)
		body   = {
			driver_track_point:{
				mobile:"15910676326",
				lat:"8",
				lng:"8",
				radius: 100,
				coortype: 'gsm'
			}
		}.to_json
		request_header = {'Content-Type' =>'application/json',"Cookie" => "remember_token=#{cookie["token_value"]}"}
		self.post_request(path,request_header,body)
	end
	def taxi_requests_index_api
		path ="/api/v1/taxi_requests?lat=8&lng=8&radius=10"
		request_header = self.get_passenger_head
		self.get_request(path,request_header)
	end
	def driver_signin_api
		path = "/api/v1/sessions/driver_signin"
		_signin(path)
	end
	def passenger_signin_api
		path = "/api/v1/sessions/passenger_signin"
		_signin(path)
	end
	def _signin(path)
		body = {session:{mobile:"15910676326",password:"8"}}.to_json
		request_header = {'Content-Type' =>'application/json'}
		self.post_request(path,request_header,body)
	end
	def get_driver_head
		cookie = JSON.parse(self.driver_signin_api)
		request_header ={'Content-Type' =>'application/json',"Cookie" => "remember_token=#{cookie["token_value"]}"}
	end
	def get_passenger_head
		cookie = JSON.parse(self.passenger_signin_api)
		request_header = {'Content-Type' =>'application/json',"Cookie" => "remember_token=#{cookie["token_value"]}"}
	end
	def post_request(path,header,body)
		request 		= Net::HTTP::Post.new(path, initheader = header )
		request.body 	= body
		response = Net::HTTP.new(@host, @port).start {|http| http.request(request) }
		puts "Response #{response.code} #{response.message}: #{response.body}"
		response.body
	end

	def get_request(path,header)
		request = Net::HTTP::Get.new(path,initheader = header)
		response = Net::HTTP.new(@host, @port).start {|http| http.request(request) }
		puts response.body
	end


end

s = TestApi.new
#s.passenger_signin_api
#s.create_taxi_request_api
#s.create_driver_track_point_api
#s.taxi_requests_index_api
#s.answer_taxi_request_api
#s.show_taxi_request_api
#s.cancel_taxi_request_api
s.confirm_taxi_request_api


