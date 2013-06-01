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

	DEFUALT_JSON_RESULT 					 = {
													:only	 => [:id,:state,:passenger_mobile,:driver_mobile],
													:methods => [:passenger_lat,:passenger_lng,:passenger_voice_url,:driver_lat,:driver_lng]
											   }
	default_scope { where(tenant_id: Tenant.current_id)  if Tenant.current_id }

	attr_accessor :passenger_lng,:passenger_lat,:waiting_time_range,:passenger_voice_format
	attr_accessor :response_driver,:response_info

	scope :by_distance,lambda { |driver_location,radius|
		where("ST_DWithin(ST_GeographyFromText('SRID=4326;#{driver_location.to_s}'),passenger_location,#{radius})");
	}
	scope :within,lambda {|s|
		where("created_at >= ? " ,s.minutes.ago)
	}
	scope :by_state,lambda {|state='Waiting_Driver_Response'|
		where('state = ?',state)
	}
	def driver_lat
		self.driver_location.try(:y)
	end
	def driver_lng
		self.driver_location.try(:x)
	end
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
	def passenger_confirm(params,current_passenger)
		self.state_event				= 'Passenger_Confirm'
		self.save
	end
	#测试状态
	def passenger_cancel(params,current_passenger)
		self.state_event 				= 'Passenger_Cancel'
		self.save
	end
	#测试状态
	def passenger_confirm(params,current_passenger)
		self.state_event 				= 'Passenger_Confirm'
		self.save
	end
	#测试状态
	def driver_response(params,current_driver)
		#优化如果非waiting_driver_confirm 直接返回
		self.response_driver 			= current_driver
		self.response_info 				= params
		self.state_event 				= 'Driver_Confirm'
		self.save
	end

	state_machine :initial => :Waiting_Driver_Response do
		before_transition any => :Canceled_By_Passenger ,:do => :set_passenger_cancel_time
		before_transition :Waiting_Passenger_Confirm => :Success ,:do => :set_passenger_confirm_time
		before_transition :Waiting_Driver_Response   => :Waiting_Passenger_Confirm, :do => :set_response_info
		around_transition do |taxi_request, transition, block|
			Rails.logger.debug "before #{transition.event}: #{taxi_request.state} "
			block.call
			Rails.logger.debug "after #{transition.event}: #{taxi_request.state} "
		end

		state :Waiting_Driver_Response do
			transition :to => :Waiting_Driver_Response      ,:on => :Passenger_Confirm
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
	private 
	def set_passenger_cancel_time
		self.passenger_cancel_time = Time.now
	end
	def set_passenger_confirm_time
		self.passenger_confirm_time = Time.now
	end
	def set_response_info
		self.driver_mobile				= self.response_info[:driver_mobile]
		self.driver_id 					= self.response_driver.id
		if self.response_info and self.response_info[:driver_lng] and self.response_info[:driver_lat]
			self.driver_location = "POINT(#{self.response_info[:driver_lng]} #{self.response_info[:driver_lat]})"
		end
		self.driver_response_time 		= Time.now
		self.timeout 					= DEFAULT_WAITING_PASSENGER_CONFIRM_TIME_S.seconds.since
	end
end
