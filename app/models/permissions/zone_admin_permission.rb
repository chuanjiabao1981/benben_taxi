module Permissions
  class ZoneAdminPermission < BasePermission
    def initialize(user)
    	super(user)
    	allow "api/v1/driver_track_points"    , [:index]
    	allow "api/v1/taxi_requests",[:index]
    end
  end
end