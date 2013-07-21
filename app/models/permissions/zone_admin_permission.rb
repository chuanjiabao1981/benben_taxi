module Permissions
  class ZoneAdminPermission < BasePermission
    def initialize(user)
    	super(user)
    	allow "api/v1/driver_track_points"    , [:index]
    	allow "api/v1/taxi_requests",[:latest]
        
    	allow "zone_admin/users",[:index,:new,:create]
        allow "zone_admin/users",[:edit,:update,:destroy,:show] do |k|
            k && k.tenant_id == user.tenant_id
        end
        allow_param :user,[:name,:mobile,:password,:password_confirmation,:plate,:register_info,:status,:taxi_company_id]

    	allow "zone_admin/taxi_companies",[:index,:new,:create]
        allow "zone_admin/taxi_companies",[:destroy,:edit,:update] do |k|
            k && k.tenant_id == user.tenant_id
        end
    	allow_param :taxi_company,[:name,:boss]

        allow "zone_admin/taxi_requests",[:show] do |t|
            t && t.tenant_id == user.tenant_id
        end

        allow "zone_admin/advertisements",[:index,:new,:create]
    end
  end
end