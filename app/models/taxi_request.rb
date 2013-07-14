#encoding:utf-8
class TaxiRequest < ActiveRecord::Base

	require 'carrierwave/orm/activerecord'
	
	self.per_page = 10

	validates_presence_of :passenger_mobile
	validates_presence_of :passenger_id
	validates_presence_of :passenger_location
	validates_presence_of :tenant_id
	validates_presence_of :timeout


	mount_uploader :passenger_voice,PassengerVoiceUploader
	has_many :comments,:as => :commentable
	belongs_to :passenger, 	:class_name=>"User",:foreign_key => "passenger_id"
	belongs_to :driver,		:class_name=>"User",:foreign_key => "driver_id"


	DEFAULT_WAITING_TIME_RANGE = 5


	accepts_nested_attributes_for :comments


	#5公里
	DEFAULT_SEARCH_RADIUS 	   				= 5000 
	MAX_WAITING_TIME_RANGE 	   				= 20
	TMP_FILE_NAME 			   				= 'benben_taxi'
	ORIGINAL_FILENAME 		   				= 'benben_taxi_passenger_voice'

	DEFAULT_WAITING_PASSENGER_CONFIRM_TIME_S = 50

	DEFUALT_JSON_RESULT 					 = {
													:only	 => [:id,:state,:passenger_mobile,:driver_mobile,:driver_score,:passenger_score,:plate,:driver_name,:source,:destination,:created_at],
													:methods => [:passenger_lat,:passenger_lng,:passenger_voice_url,:driver_lat,:driver_lng,:passenger_has_score,:driver_has_score]
											   }
	DEFAULT_JSON_RESULT_WITH_COMMENTS		 = DEFUALT_JSON_RESULT.merge(
													{
														:include=> {
															:comments=>{:only=>[:author_id,:author_role,:content,:created_at]}
														}
													}
											   )
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

	scope :timeout_taxi_requests ,lambda {
		where('(state=? or state=?) and 
			   (timeout is not null and timeout <= ?)',
			   'Waiting_Driver_Response',
			   'Waiting_Passenger_Confirm',
			   Time.now)
	}
	scope :today ,lambda{
		where('created_at >= ? ',Time.now.beginning_of_day)
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

	def passenger_has_score
		return true if self.passenger_score_time
		false	
	end
	def driver_has_score
		return true if self.driver_score_time
		false
	end
	def taxi_request_desc
	end

	def self.get_nearby_taxi_requests(params)
		return [] if params[:lng].nil? or params[:lat].nil?
		params[:radius] ||=DEFAULT_SEARCH_RADIUS
		driver_location = "POINT (#{params[:lng]} #{params[:lat]})"
		s=TaxiRequest.all.by_distance(driver_location,params[:radius]).by_state.within(MAX_WAITING_TIME_RANGE*2).order("created_at DESC")
		s.as_json(DEFUALT_JSON_RESULT)
	end
	def self.get_latest_taxi_requests
		s=TaxiRequest.all.within(MAX_WAITING_TIME_RANGE*2).order("created_at DESC").limit(10);
		#s.as_json(:only=>[:passenger_mobile],:methods=>[:passenger_lng,:passenger_lat,:taxi_request_desc])
		r = []
		s.each do |t|
			_t = {}
			_t[:lat] 	= t.passenger_lat
			_t[:lng] 	= t.passenger_lng
			#_t[:desc] 	= "#{t.created_at.strftime("%m-%d %H:%M")} #{t.state}"
			_t[:desc]   = "乘客 #{t.passenger_mobile}"
			r <<_t
		end
		r.as_json
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
	def set_timeout
		ensure_no_confilit do
			self.state_event = 'TimeOut'
			self.save
		end
	end
	def passenger_confirm(params,current_passenger)
		ensure_no_confilit do
			self.state_event				= 'Passenger_Confirm'
			self.save
		end
	end
	def passenger_cancel(params,current_passenger)
		ensure_no_confilit do
			self.state_event 				= 'Passenger_Cancel'
			self.save
		end
	end
	def passenger_confirm(params,current_passenger)
		ensure_no_confilit do
			self.state_event 				= 'Passenger_Confirm'
			self.save
		end
	end
	def driver_response(params,current_driver)
		ensure_no_confilit do
			self.response_driver 			= current_driver
			self.response_info 				= params
			self.state_event 				= 'Driver_Confirm'
			self.save
		end
	end

	def ensure_no_confilit
		n = 0
		begin
			yield
		rescue ActiveRecord::StaleObjectError
			n = n + 1
			old_state 			= self.state
			old_lock_version	= self.lock_version
			self.reload
			Rails.logger.info "Conflict #{self.id} old state is [#{old_state}][#{old_lock_version}] new state is [#{self.state}][#{self.lock_version}] Reload #{n}"
			if  n < 2
				retry
			else
				Rails.logger.info "Fail Confilict!"
				self
			end
		end
	end

	def comment_on_passenger(params,current_user)
		passenger_score = params[:passenger_score]
		if (passenger_score and (passenger_score.to_i <1 or passenger_score.to_i > 5) )
			return true
		elsif passenger_score
			params[:passenger_score_time] = Time.now
		end
		if params[:comments_attributes] and params[:comments_attributes][0]
			params[:comments_attributes][0][:author_id] 	= current_user.id
			params[:comments_attributes][0][:author_role] 	= current_user.role
			params[:comments_attributes][0][:target_id] 	= self.passenger_id
			params[:comments_attributes][0][:target_role]   = User::ROLE_PASSENGER
		end
		self.update(params)
	end

	def comment_on_driver(params,current_user)
		driver_score = params[:driver_score]
		if (driver_score and (driver_score.to_i < 1 or driver_score.to_i > 5))
			return true
		elsif driver_score
			params[:driver_score_time] = Time.now
		end
		if params[:comments_attributes] and params[:comments_attributes][0]
			params[:comments_attributes][0][:author_id] 	= current_user.id
			params[:comments_attributes][0][:author_role] 	= current_user.role
			params[:comments_attributes][0][:target_id] 	= self.driver_id
			params[:comments_attributes][0][:target_role]   = User::ROLE_DRIVER
		end
		self.update(params)
	end

	def self.today_success_requests
		TaxiRequest.today.where(state: 'Success').count
	end
	


	state_machine :initial => :Waiting_Driver_Response do
		before_transition all => :Canceled_By_Passenger ,:do => :set_passenger_cancel_time
		before_transition :Waiting_Passenger_Confirm => :Success ,:do => :set_passenger_confirm_time
		after_transition  :Waiting_Passenger_Confirm => :Success ,:do => :update_statistics_info
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

		event all do
			transition :Canceled_By_Passenger => :Canceled_By_Passenger
			transition :Success 			  => :Success
			transition :TimeOut 			  => :TimeOut
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
		self.driver_name 				= self.response_driver.name
		self.plate 						= self.response_driver.plate
		if self.response_info and self.response_info[:driver_lng] and self.response_info[:driver_lat]
			self.driver_location = "POINT(#{self.response_info[:driver_lng]} #{self.response_info[:driver_lat]})"
		end
		self.driver_response_time 		= Time.now
		self.timeout 					= DEFAULT_WAITING_PASSENGER_CONFIRM_TIME_S.seconds.since
	end
	def update_statistics_info
		User.where(:id=>[self.driver_id,self.passenger_id]).update_all("success_taxi_requests = success_taxi_requests + 1")
	end
end
