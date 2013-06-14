module Permissions
  class ZoneAdminPermission < BasePermission
    def initialize(user)
    	super(user)
    	allow "api/v1/driver_track_points"    , [:index]
    	allow "api/v1/taxi_requests",[:index]
    	allow "zone_admin/users",[:index]
    	allow "zone_admin/taxi_companies",[:index,:new,:create]
        allow "zone_admin/taxi_companies",[:destroy] do |k|
            k && k.tenant_id == user.tenant_id
        end
    	allow_param :taxi_company,[:name,:boss]
    end
  end
end