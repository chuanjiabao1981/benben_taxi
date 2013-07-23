#!/usr/bin/env ruby

require 'net/http'
require 'json'
require "base64"
require 'trollop'

class TaxiApi
	def initialize
		@host = 'localhost'
		#@host = 'v2.365check.net'
		@port = '8081'
	end

	def driver_signin_api(mobile=nil)
		mobile ||="15910676326"
		path = "/api/v1/sessions/driver_signin"
		_signin(path,mobile)
	end
	def passenger_signin_api(mobile=nil)
		mobile ||="15910676326"
		path = "/api/v1/sessions/passenger_signin"
		_signin(path,mobile)
	end
	def get_passenger_header(mobile=nil)
		mobile ||="15910676326"
		cookie = JSON.parse(self.passenger_signin_api(mobile))
		"--header=\"Cookie:remember_token=#{cookie["token_value"]}\""
	end
	def get_driver_header(mobile=nil)
		mobile ||="15910676326"
		cookie = JSON.parse(self.driver_signin_api(mobile))
		"--header=\"Cookie:remember_token=#{cookie["token_value"]}\""
	end
	def _signin(path,mobile)
		body = {session:{mobile:mobile,password:"8"}}.to_json
		request_header = {'Content-Type' =>'application/json'}
		self.post_request(path,request_header,body)
	end
	def get_driver_head(mobile=nil)
		cookie = JSON.parse(self.driver_signin_api(mobile))
		request_header ={'Content-Type' =>'application/json',"Cookie" => "remember_token=#{cookie["token_value"]}"}
	end
	def get_passenger_head(mobile=nil)
		cookie = JSON.parse(self.passenger_signin_api(mobile))
		request_header = {'Content-Type' =>'application/json',"Cookie" => "remember_token=#{cookie["token_value"]}"}
	end
	def post_request(path,header,body)
		request 		= Net::HTTP::Post.new(path, initheader = header )
		request.body 	= body
		response = Net::HTTP.new(@host, @port).start {|http| http.request(request) }
		#puts "Response #{response.code} #{response.message}: #{response.body}"
		response.body
	end

	def get_request(path,header)
		request = Net::HTTP::Get.new(path,initheader = header)
		response = Net::HTTP.new(@host, @port).start {|http| http.request(request) }
		#puts response.body
		response.body
	end


end
opts = Trollop::options do
	opt :passenger ,"passenger http header", :short => "-p"
	opt :driver    ,"driver http header",:short => "-d"
end

s = TaxiApi.new
if opts[:passenger]
	print "#{s.get_passenger_header} --header=\"Content-Type:application/json\""
elsif opts[:driver]
	print s.get_driver_header + " --header=\"Content-Type:application/json\""
end
