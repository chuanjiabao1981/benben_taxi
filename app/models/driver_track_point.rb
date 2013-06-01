class DriverTrackPoint < ActiveRecord::Base
	validates_presence_of :driver_id
	validates_presence_of :mobile
	validates_presence_of :location
	validates_presence_of :tenant_id

	DEFAULT_DRIVER_TIME_RANGE = 20
	DEFAULT_SEARCH_RADIUS 	  = 5000
	belongs_to :driver,		:class_name=>"User",:foreign_key => "driver_id"
	attr_accessor :lat,:lng 

	scope :by_distance,lambda { |passenger_location,radius|
		where("ST_DWithin(ST_GeographyFromText('SRID=4326;#{passenger_location.to_s}'),location,#{radius})");
	}
	scope :within,lambda {|s|
		where("created_at >= ? " ,s.minutes.ago)
	}

	default_scope { where(tenant_id: Tenant.current_id)  if Tenant.current_id }

	def self.build_driver_track_point(params,current_user)
		a = DriverTrackPoint.new(params)
		if params and params[:lng] and params[:lat]
			a.location="POINT(#{params[:lng]} #{params[:lat]})"
		end
		a.driver_id 			= current_user.id
		a
	end

	def self.get_latest_drivers(params)
		return [] if params[:lng].nil? or params[:lat].nil?
		passenger_location = "POINT (#{params[:lng]} #{params[:lat]})"
		params[:radius] 	||=DEFAULT_SEARCH_RADIUS
		params[:time_range] ||=DEFAULT_DRIVER_TIME_RANGE
		r 					  =DriverTrackPoint.select("DISTINCT on (driver_id) driver_id,created_at,location").
							   by_distance(passenger_location,params[:radius] ).
							   within(params[:time_range]).
							   order("driver_id,created_at DESC")
		r.as_json(:only=>[:driver_id,:created_at],:methods => [:lat,:lng])
	end
	def lat
		self.location.try(:y)
	end
	def lng
		self.location.try(:x)
	end
end
