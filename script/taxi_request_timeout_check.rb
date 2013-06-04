#!/usr/bin/env ruby
require 'rubygems'
require 'daemons'


class TaxiRequestTimeoutCheck
	def initialize(driver_mobile="15910676326",driver_lng=113.959805,driver_lat=22.540545)
		@driver_mobiles = ["15910676326","13810025096"]
		@driver_lng    = driver_lng
		@driver_lat    = driver_lat
	end
	def check
		loop do
			check_time_out_taxi_requests
			response_taxi_request
			add_driver_track_point
			sleep(10)
		end
	end
	def logger
		@@logger ||=  Logger.new("#{::Rails.root.to_s}/log/taxi_requests_timeout_check_daemon.log")
	end

	private 
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
		@driver_mobiles.each do |mobile|
			params= {}
			params[:mobile] = mobile
			params[:lat] 	= @driver_lat + Random.new.rand(0..30)/100000.0
			params[:lng] 	= @driver_lng + Random.new.rand(0..30)/100000.0
			current_driver  = User.find_by mobile: mobile, role: "driver"
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
	def response_taxi_request
		TaxiRequest.by_state.each do |taxi_request|
			driver_mobile 		 = @driver_mobiles[0]
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
		 val + Random.new.rand(0..50)/100000.0
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
