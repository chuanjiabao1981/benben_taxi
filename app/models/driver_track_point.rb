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
	scope :by_driver_id,lambda { |id|
		where("driver_id = ?",id)
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

	def self.get_latest_nearby_drivers(params)
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

	def self.get_drivers_latest_track_point(params)
		r = DriverTrackPoint.select("DISTINCT on (driver_id) driver_id,created_at,location,mobile")
						    .within(DEFAULT_DRIVER_TIME_RANGE)
						    .order("driver_id,created_at DESC")
		r.as_json(only:[:id,:driver_id],:methods=>[:lat,:lng,:desc])
	end
	def self.get_latest_drivers_num
		DriverTrackPoint.within(DEFAULT_DRIVER_TIME_RANGE).count(:driver_id,distinct: true)
	end
	def desc
		"#{self.mobile}
		#{self.created_at.strftime("%m-%d %H:%M")}"
	end
	def lat
		self.location.try(:y)
	end
	def lng
		self.location.try(:x)
	end
end
