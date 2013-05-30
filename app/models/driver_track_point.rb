class DriverTrackPoint < ActiveRecord::Base
	validates_presence_of :driver_id
	validates_presence_of :mobile
	validates_presence_of :location
	validates_presence_of :tenant_id

	belongs_to :driver,		:class_name=>"User",:foreign_key => "driver_id"
	attr_accessor :lat,:lng 

	default_scope { where(tenant_id: Tenant.current_id)  if Tenant.current_id }

	def self.build_driver_track_point(params,current_user)
		a = DriverTrackPoint.new(params)
		if params and params[:lng] and params[:lat]
			a.location="POINT(#{params[:lng]} #{params[:lat]})"
		end
		a.driver_id 			= current_user.id
		a
	end
end
