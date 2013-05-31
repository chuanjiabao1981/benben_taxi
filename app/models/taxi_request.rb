#encoding:utf-8
class TaxiRequest < ActiveRecord::Base

	require 'carrierwave/orm/activerecord'


	validates_presence_of :passenger_mobile
	validates_presence_of :passenger_id
	validates_presence_of :passenger_location
	validates_presence_of :tenant_id
	validates_presence_of :timeout


	mount_uploader :passenger_voice,PassengerVoiceUploader

	belongs_to :passenger, 	:class_name=>"User",:foreign_key => "passenger_id"
	belongs_to :driver,		:class_name=>"User",:foreign_key => "driver_id"


	DEFAULT_WAITING_TIME_RANGE = 5

	#5公里
	DEFAULT_SEARCH_RADIUS 	   				= 5000 
	MAX_WAITING_TIME_RANGE 	   				= 20
	TMP_FILE_NAME 			   				= 'benben_taxi'
	ORIGINAL_FILENAME 		   				= 'benben_taxi_passenger_voice'

	DEFAULT_WAITING_PASSENGER_CONFIRM_TIME_S = 20

	DEFUALT_JSON_RESULT 					 = {:only=>[:id,:state],:methods => [:passenger_lat,:passenger_lng,:passenger_voice_url]}
	default_scope { where(tenant_id: Tenant.current_id)  if Tenant.current_id }

	attr_accessor :passenger_lng,:passenger_lat,:waiting_time_range,:passenger_voice_format

	scope :by_distance,lambda { |driver_location,radius|
		where("ST_DWithin(ST_GeographyFromText('SRID=4326;#{driver_location.to_s}'),passenger_location,#{radius})");
	}
	scope :within,lambda {|s|
		where("created_at >= ? " ,s.minutes.ago)
	}
	scope :by_state,lambda {|state='Waiting_Driver_Response'|
		where('state = ?',state)
	}

	def passenger_lng
		self.passenger_location.x
	end
	def passenger_lat
		self.passenger_location.y
	end

	def passenger_voice_url
		self.passenger_voice.url
	end

	def self.get_latest_taxi_requests(params)

		Rails.logger.debug("00001112312341234124134231")
		return [] if params[:lng].nil? or params[:lat].nil?
		params[:radius] ||=DEFAULT_SEARCH_RADIUS
		driver_location = "POINT (#{params[:lng]} #{params[:lat]})"
		s=TaxiRequest.all.by_distance(driver_location,params[:radius]).by_state.within(MAX_WAITING_TIME_RANGE*2).order("created_at DESC")
		s.as_json(DEFUALT_JSON_RESULT)
	end
	def self.build_taxi_request(params,current_user)
		if params and params[:passenger_lng] and params[:passenger_lat]
			passenger_location="POINT(#{params[:passenger_lng]} #{params[:passenger_lat]})"
		end
		s = params[:waiting_time_range].to_i
		s = DEFAULT_WAITING_TIME_RANGE  if s == 0 or s > MAX_WAITING_TIME_RANGE
		a = TaxiRequest.new(params)
		a.passenger_id 			= current_user.id
		a.passenger_location 	= passenger_location
		a.timeout 				= s.minutes.since
		a.passenger_voice 		= get_http_uploader_file(params)
		a
	end

	def get_json
		self.as_json(DEFUALT_JSON_RESULT)
	end
		
	#测试状态
	def driver_response(params,current_driver)
		self.state_event 				= 'Driver_Confirm'
		self.driver_mobile				= params[:driver_mobile]
		self.driver_id 					= current_driver.id
		if params and params[:driver_lng] and params[:driver_lat]
			self.driver_location = "POINT(#{params[:driver_lng]} #{params[:driver_lat]})"
		end
		self.driver_response_time 		= Time.now
		self.timeout 					= DEFAULT_WAITING_PASSENGER_CONFIRM_TIME_S.seconds.since
		self.save
	end


	state_machine :initial => :Waiting_Driver_Response do
		around_transition do |taxi_request, transition, block|
			Rails.logger.debug "before #{transition.event}: #{taxi_request.state} "
			block.call
			Rails.logger.debug "after #{transition.event}: #{taxi_request.state} "
		end

		state :Waiting_Driver_Response do
			transition :to => :Canceled_By_Passenger 		,:on => :Passenger_Cancel
			transition :to => :Waiting_Passenger_Confirm 	,:on => :Driver_Confirm
			transition :to => :TimeOut						,:on => :TimeOut
		end

		state :Canceled_By_Passenger do
			transition :to => :Canceled_By_Passenger 		,:on => :any
		end

		state :Waiting_Passenger_Confirm do
			validates_presence_of :driver_id
			validates_presence_of :driver_mobile
			validates_presence_of :driver_location
			validates_presence_of :driver_response_time

			transition :to => :Canceled_By_Passenger		,:on => :Passenger_Cancel
			transition :to => :Success 					,:on => :Passenger_Confirm
			transition :to => :Waiting_Passenger_Confirm 	,:on => :Driver_Confirm
			transition :to => :TimeOut 						,:on => :TimeOut
		end

		state :Success do
			transition :to => :Success 							,:on => :any
		end

		state :TimeOut do
			transition :to => :TimeOut 							,:on => :any
		end
	end

	def self.get_http_uploader_file(params)
		return nil if params[:passenger_voice].nil?
		tempfile = Tempfile.new(TMP_FILE_NAME)
		tempfile.binmode
		tempfile.write(Base64.decode64(params[:passenger_voice]))
		tempfile.rewind()
		voice_format = params[:passenger_voice_format].nil? ?  "m4a" : params[:passenger_voice_format]
		uploaded_file = ActionDispatch::Http::UploadedFile.new(
					:tempfile => tempfile, 
					:filename => "#{ORIGINAL_FILENAME}.#{voice_format}")
	end

end
