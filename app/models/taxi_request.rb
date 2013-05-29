class TaxiRequest < ActiveRecord::Base

	validates_presence_of :passenger_mobile
	validates_presence_of :passenger_id
	validates_presence_of :passenger_location
	validates_presence_of :tenant_id
	validates_presence_of :timeout

	belongs_to :passenger, 	:class_name=>"User",:foreign_key => "passenger_id"
	belongs_to :driver,		:class_name=>"User",:foreign_key => "driver_id"

	DEFAULT_WAITING_TIME_RANGE = 5
	MAX_WAITING_TIME_RANGE 	   = 20

	default_scope { where(tenant_id: Tenant.current_id)  if Tenant.current_id }


	def self.build_taxi_request(params,current_user)
		if params and params[:passenger_lng] and params[:passenger_lat]
			passenger_location="POINT(#{params[:passenger_lng]} #{params[:passenger_lat]})"
		end
		s = params[:waiting_time_range].to_i
		s = DEFAULT_WAITING_TIME_RANGE  if s == 0 or s > MAX_WAITING_TIME_RANGE
		params.delete(:passenger_lng)
		params.delete(:passenger_lat)
		params.delete(:waiting_time_range)
		a = TaxiRequest.new(params)
		a.passenger_id = current_user.id
		a.passenger_location = passenger_location
		a.timeout = s.minutes.since
		a
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

end
