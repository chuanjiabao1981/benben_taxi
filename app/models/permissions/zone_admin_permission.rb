module Permissions
  class ZoneAdminPermission < BasePermission
    def initialize(user)
    	super(user)

    	allow "api/v1/driver_track_points"    , [:index]
    end
  end
end