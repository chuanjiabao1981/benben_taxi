#!/usr/bin/env ruby
require 'rubygems'
require 'daemons'


class TaxiRequestTimeoutCheck
	def initialize(driver_mobile="15910676326",driver_lng=113.959805,driver_lat=22.540545)
		@driver_mobiles = ["15910676326","13810025096"]
		@driver_lng    = driver_lng
		@driver_lat    = driver_lat
		@passengers	   = [
						   {
						   		mobile: "11111111111",
						   		lng:113.999805,
						   		lat:22.550666,
						   },
						   {
						   		mobile: "22222222222",
						   		lng:113.889800,
						   		lat:22.560666
						   }	
		]
		@drivers 		= [
			{
				mobile: "25910676326",
				lng: 116.522284,
				lat: 39.938478
			},
			{
				mobile: "15910676326",
				lng:113.999805,
				lat:22.550666
			},
			{
				mobile: "23810025096",
				lng: 116.522284,
				lat: 39.938478
			},
			{
				mobile: "13810025096",
				lng:113.999805,
				lat:22.550666
			},

		]
		check_passengers
		check_drivers
	end
	def check
		loop_counter = 0
		add_taxi_request_thred = 10

		loop do
			check_time_out_taxi_requests
			response_taxi_request
			add_driver_track_point
			if (loop_counter % add_taxi_request_thred == 0)
				add_taxi_requests
			end
			loop_counter = loop_counter + 1
			sleep(1)
		end
	end
	def logger
		@@logger ||=  Logger.new("#{::Rails.root.to_s}/log/taxi_requests_timeout_check_daemon.log")
	end

	private 
	def check_passengers
		@passengers.each do |p|
			if not User.find_by mobile: p[:mobile],role: User::ROLE_PASSENGER
				User.build_passenger(mobile: p[:mobile],password: '8',password_confirmation: '8').save
				puts "not found"
			end
		end
	end
	def check_drivers
		@drivers.each do |d|
			if not User.find_by mobile: d[:mobile],role: User::ROLE_DRIVER
				User.build_driver(mobile: d[:mobile],password: '8',password_confirmation: '8').save
				puts "not found"
			end
		end
	end
	def add_taxi_requests
		@passengers.each do |p|

			current_passenger  = User.find_by mobile: p[:mobile],role: User::ROLE_PASSENGER

			params = {}
			params[:passenger_mobile] = p[:mobile]
			params[:passenger_lng] = get_random(p[:lng])
			params[:passenger_lat] = get_random(p[:lat])

			if current_passenger
				r=TaxiRequest.build_taxi_request(params,current_passenger)
				r.tenant_id = current_passenger.tenant_id
				if r.save
					logger.info "taxi requests at #{params[:passenger_lng]} #{params[:passenger_lat]} #{p[:mobile]}";
				else
					logger.warn r.errors.full_messages
				end
			else
				logger.warn "No Passenger Found #{p[:mobile]}"
			end
		end
	end
	def check_time_out_taxi_requests
		start_time = Time.now
		ss = []
		TaxiRequest.timeout_taxi_requests.each do |taxi_request|
			taxi_request.set_timeout
			ss << taxi_request.id
		end
		used_time=Time.now - start_time
		logger.info "#{start_time}|#{used_time}|#{ss}"
	end

	def add_driver_track_point
		@drivers.each do |d|
			params= {}
			params[:mobile] = d[:mobile]
			params[:lat] 	= get_random(d[:lat])
			params[:lng] 	= get_random(d[:lng])
			current_driver  = get_current_driver(params[:mobile])
			if current_driver
				params[:tenant_id] = current_driver.tenant_id
				a=DriverTrackPoint.build_driver_track_point(params,current_driver)
				if not a.save
					logger.warn a.errors
				end
			else
				logger.warn "No Driver Found #{mobile}"
			end 	
		end
	end
	#def add_driver_track_point
	#	@driver_mobiles.each do |mobile|
	#		params= {}
	#		params[:mobile] = mobile
	#		params[:lat] 	= get_random(@driver_lat)
	#		params[:lng] 	= get_random(@driver_lng)
	#		current_driver  = User.find_by mobile: mobile, role: "driver"
	#		if current_driver
	#			params[:tenant_id] = current_driver.tenant_id
	#			a=DriverTrackPoint.build_driver_track_point(params,current_driver)
	#			if not a.save
	#				logger.warn a.errors
	#			end
	#		else
	#			logger.warn "No Driver Found #{mobile}"
	#		end
	#	end
	#end
	def response_taxi_request
		TaxiRequest.by_state.each do |taxi_request|
			driver_mobile 		 = @drivers[0][:mobile]
			current_driver	 	 = get_current_driver(driver_mobile)
			params = {
						taxi_response:{
							driver_mobile: driver_mobile,
							driver_lat: get_random(@driver_lat),
							driver_lng: get_random(@driver_lng)
						}
					}
			if current_driver
				taxi_request.driver_response(params[:taxi_response],current_driver)
				if taxi_request.state == 'Waiting_Passenger_Confirm' 
					logger.info "#{driver_mobile} response the taxi_request #{taxi_request.id}"
				end
			else
				logger.warn "No Driver Found #{driver_mobile} to response the taxi request #{taxi_request.id}"
			end

		end
	end
	def get_random(val)
		 val + Random.new.rand(10..400)/10000.0
	end
	def get_current_driver(mobile)
		User.find_by mobile: mobile, role: "driver"
	end
end



###异常和启动日志在 ./tmp/pids/xxxx.log内
dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))
daemon_options = {
  :multiple   => false,
  :dir_mode   => :normal,
  :dir        => File.join(dir, 'tmp', 'pids'),
  :backtrace  => true,
  :monitor    => true
}
RAILS_RUNNING_ENV=File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))


Daemons.run_proc('TaxiRequestTimeoutCheck', daemon_options) do
  if ARGV.include?('--')
    ARGV.slice! 0..ARGV.index('--')
  else
    ARGV.clear
  end
  ENV["RAILS_ENV"] 		||=  "production"
  Dir.chdir dir
  require  RAILS_RUNNING_ENV
  TaxiRequestTimeoutCheck.new.check
end
